package com.ferdinandsilva.printerpt220

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.ColorFilter
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint

object Util {
  private val p0 = intArrayOf(0, 128)

  private val p1 = intArrayOf(0, 64)

  private val p2 = intArrayOf(0, 32)

  private val p3 = intArrayOf(0, 16)

  private val p4 = intArrayOf(0, 8)

  private val p5 = intArrayOf(0, 4)

  private val p6 = intArrayOf(0, 2)

  private val Floyd16x16 = arrayOf(
    intArrayOf(
      0, 128, 32, 160, 8, 136, 40, 168, 2, 130,
      34, 162, 10, 138, 42, 170
    ), intArrayOf(
      192, 64, 224, 96, 200, 72, 232, 104, 194, 66,
      226, 98, 202, 74, 234, 106
    ), intArrayOf(
      48, 176, 16, 144, 56, 184, 24, 152, 50, 178,
      18, 146, 58, 186, 26, 154
    ), intArrayOf(
      240, 112, 208, 80, 248, 120, 216, 88, 242, 114,
      210, 82, 250, 122, 218, 90
    ), intArrayOf(
      12, 140, 44, 172, 4, 132, 36, 164, 14, 142,
      46, 174, 6, 134, 38, 166
    ), intArrayOf(
      204, 76, 236, 108, 196, 68, 228, 100, 206, 78,
      238, 110, 198, 70, 230, 102
    ), intArrayOf(
      60, 188, 28, 156, 52, 180, 20, 148, 62, 190,
      30, 158, 54, 182, 22, 150
    ), intArrayOf(
      252, 124, 220, 92, 244, 116, 212, 84, 254, 126,
      222, 94, 246, 118, 214, 86
    ), intArrayOf(
      3, 131, 35, 163, 11, 139, 43, 171, 1, 129,
      33, 161, 9, 137, 41, 169
    ), intArrayOf(
      195, 67, 227, 99, 203, 75, 235, 107, 193, 65,
      225, 97, 201, 73, 233, 105
    ), intArrayOf(
      51, 179, 19, 147, 59, 187, 27, 155, 49, 177,
      17, 145, 57, 185, 25, 153
    ), intArrayOf(
      243, 115, 211, 83, 251, 123, 219, 91, 241, 113,
      209, 81, 249, 121, 217, 89
    ), intArrayOf(
      15, 143, 47, 175, 7, 135, 39, 167, 13, 141,
      45, 173, 5, 133, 37, 165
    ), intArrayOf(
      207, 79, 239, 111, 199, 71, 231, 103, 205, 77,
      237, 109, 197, 69, 229, 101
    ), intArrayOf(
      63, 191, 31, 159, 55, 183, 23, 151, 61, 189,
      29, 157, 53, 181, 21, 149
    ), intArrayOf(
      254, 127, 223, 95, 247, 119, 215, 87, 253, 125,
      221, 93, 245, 117, 213, 85
    )
  )

  fun toGrayscale(bmpOriginal: Bitmap): Bitmap {
    val height = bmpOriginal.height
    val width = bmpOriginal.width
    val bmpGrayscale = Bitmap.createBitmap(width, height, Bitmap.Config.RGB_565)
    val c = Canvas(bmpGrayscale)
    val paint = Paint()
    val cm = ColorMatrix()
    cm.setSaturation(0.0f)
    val f = ColorMatrixColorFilter(cm)
    paint.setColorFilter(f as ColorFilter)
    c.drawBitmap(bmpOriginal, 0.0f, 0.0f, paint)
    return bmpGrayscale
  }

  private fun formatKDither16x16(
    orgpixels: IntArray,
    xsize: Int,
    ysize: Int,
    despixels: ByteArray
  ) {
    var k = 0
    for (y in 0 until ysize) {
      for (x in 0 until xsize) {
        if (orgpixels[k] and 0xFF > Floyd16x16[x and 0xF][y and 0xF]) {
          despixels[k] = 0
        } else {
          despixels[k] = 1
        }
        k++
      }
    }
  }

  fun bitmapToBWPix(mBitmap: Bitmap): ByteArray {
    val pixels = IntArray(mBitmap.width * mBitmap.height)
    val data = ByteArray(mBitmap.width * mBitmap.height)
    val grayBitmap: Bitmap = toGrayscale(mBitmap)
    grayBitmap.getPixels(
      pixels,
      0,
      mBitmap.width,
      0,
      0,
      mBitmap.width,
      mBitmap.height
    )
    val w = mBitmap.width
    val h = mBitmap.height
    formatKDither16x16(pixels, mBitmap.width, mBitmap.height, data)
    return data
  }

  fun pixToEscRastBitImageCmd(src: ByteArray): ByteArray {
    val data = ByteArray(src.size / 8)
    var i = 0
    var k = 0
    while (i < data.size) {
      data[i] =
        (p0[src[k].toInt()] + p1[src[k + 1].toInt()] + p2[
          src[k + 2].toInt()
        ] + p3[src[k + 3].toInt()] + p4[src[k + 4].toInt()] + p5[
          src[k + 5].toInt()
        ] + p6[src[k + 6].toInt()] + src[k + 7]).toByte()
      k += 8
      i++
    }
    return data
  }

}
