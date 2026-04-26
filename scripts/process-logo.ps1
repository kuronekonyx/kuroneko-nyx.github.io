Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class LogoProcessor
{
    public static void MakeWhiteTransparent(string sourcePath, string outputPath)
    {
        const int darkThreshold = 24;

        using (var sourceImage = new Bitmap(sourcePath))
        using (var source = new Bitmap(sourceImage.Width, sourceImage.Height, PixelFormat.Format32bppArgb))
        {
            using (var g = Graphics.FromImage(source))
            {
                g.DrawImage(sourceImage, 0, 0, source.Width, source.Height);
            }

            int width = source.Width;
            int height = source.Height;
            int strideLength;
            byte[] pixels = ReadPixels(source, out strideLength);
            bool[] dark = new bool[width * height];
            bool[] edge = new bool[width * height];

            for (int y = 0; y < height; y++)
            {
                int row = y * strideLength;
                for (int x = 0; x < width; x++)
                {
                    int i = row + (x * 4);
                    int b = pixels[i];
                    int g = pixels[i + 1];
                    int r = pixels[i + 2];
                    int luma = (int)(0.299 * r + 0.587 * g + 0.114 * b);
                    dark[(y * width) + x] = luma < darkThreshold;
                }
            }

            var queue = new Queue<int>();
            Action<int, int> add = (x, y) =>
            {
                if (x < 0 || x >= width || y < 0 || y >= height) return;
                int idx = (y * width) + x;
                if (dark[idx] && !edge[idx])
                {
                    edge[idx] = true;
                    queue.Enqueue(idx);
                }
            };

            for (int x = 0; x < width; x++)
            {
                add(x, 0);
                add(x, height - 1);
            }

            for (int y = 0; y < height; y++)
            {
                add(0, y);
                add(width - 1, y);
            }

            while (queue.Count > 0)
            {
                int idx = queue.Dequeue();
                int x = idx % width;
                int y = idx / width;
                add(x + 1, y);
                add(x - 1, y);
                add(x, y + 1);
                add(x, y - 1);
            }

            byte[] outputPixels = new byte[pixels.Length];

            for (int y = 0; y < height; y++)
            {
                int row = y * strideLength;
                for (int x = 0; x < width; x++)
                {
                    int pixelIndex = row + (x * 4);
                    int maskIndex = (y * width) + x;
                    int b = pixels[pixelIndex];
                    int g = pixels[pixelIndex + 1];
                    int r = pixels[pixelIndex + 2];
                    int luma = (int)(0.299 * r + 0.587 * g + 0.114 * b);

                    outputPixels[pixelIndex] = 255;
                    outputPixels[pixelIndex + 1] = 255;
                    outputPixels[pixelIndex + 2] = 255;
                    outputPixels[pixelIndex + 3] = 0;

                    if (dark[maskIndex] && !edge[maskIndex])
                    {
                        int alpha = Math.Min(255, Math.Max(52, (int)((darkThreshold - luma) * 5.4)));
                        outputPixels[pixelIndex + 3] = (byte)alpha;
                    }
                }
            }

            using (var output = new Bitmap(width, height, PixelFormat.Format32bppArgb))
            {
                WritePixels(output, outputPixels);
                output.Save(outputPath, ImageFormat.Png);
            }
        }
    }

    private static byte[] ReadPixels(Bitmap bitmap, out int strideLength)
    {
        Rectangle rect = new Rectangle(0, 0, bitmap.Width, bitmap.Height);
        BitmapData data = bitmap.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
        try
        {
            strideLength = data.Stride;
            byte[] pixels = new byte[data.Stride * data.Height];
            Marshal.Copy(data.Scan0, pixels, 0, pixels.Length);
            return pixels;
        }
        finally
        {
            bitmap.UnlockBits(data);
        }
    }

    private static void WritePixels(Bitmap bitmap, byte[] pixels)
    {
        Rectangle rect = new Rectangle(0, 0, bitmap.Width, bitmap.Height);
        BitmapData data = bitmap.LockBits(rect, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
        try
        {
            Marshal.Copy(pixels, 0, data.Scan0, pixels.Length);
        }
        finally
        {
            bitmap.UnlockBits(data);
        }
    }
}
"@

$sourcePath = (Resolve-Path ".\assets\kuro-logo-original.png").Path
$outputPath = Join-Path (Get-Location) "assets\kuro-logo-white.png"
[LogoProcessor]::MakeWhiteTransparent($sourcePath, $outputPath)
Get-Item $outputPath | Select-Object FullName,Length
