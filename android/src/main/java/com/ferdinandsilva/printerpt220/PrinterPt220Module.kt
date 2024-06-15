package com.ferdinandsilva.printerpt220

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.WritableNativeArray
import java.io.IOException
import java.util.UUID

var btAdapter: BluetoothAdapter? = null
var btDevice: BluetoothDevice? = null
var btSocket: BluetoothSocket? = null
var btDevices = hashMapOf<String, String>()

class PrinterPt220Module(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  @SuppressLint("MissingPermission")
  override fun initialize() {
    super.initialize()
    val bluetoothManager = reactApplicationContext.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    btAdapter = bluetoothManager.adapter
    if (btAdapter != null && btAdapter!!.isEnabled) {
      val pairedDevices: Set<BluetoothDevice>? = btAdapter?.bondedDevices
      pairedDevices?.forEach { device ->
        btDevices[device.name] = device.address
      }
    }
  }

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun ptGetDevices(promise: Promise) {
    var devArray = WritableNativeArray()
    for ((key, value) in btDevices) {
      devArray.pushString(key)
    }
    promise.resolve(devArray)
  }

  @ReactMethod
  fun ptConnect(name: String, promise: Promise) {
    if (btAdapter == null) {
      promise.reject("Connect event", "Bluetooth adapter is null.")
      return
    }

    if (!btAdapter!!.isEnabled) {
      promise.reject("Connect event", "Bluetooth is disabled.")
      return
    }

    if (!btDevices.containsKey(name)) {
      promise.reject("Connect event", "Invalid name.")
      return
    }

    btDevice = btAdapter?.getRemoteDevice(btDevices[name])
    val printerThread = PrinterThread(btDevice!!)
    printerThread.start()
    promise.resolve(name)
  }

  private fun printerExecute(command: ByteArray?, tag: String, promise: Promise) {
    if (btSocket == null) {
      promise.reject(tag, "Not connected to the device.")
      return
    }
    try {
      val out = btSocket?.outputStream
      out?.write(command)
      promise.resolve(true)
    } catch (e: IOException) {
      promise.reject(tag, "IOException occurred.")
    }
  }

  @ReactMethod
  fun ptSetPrinter(command: String, promise: Promise) {
    printerExecute(printerCommands[command], "Set printer", promise)
  }

  @ReactMethod
  fun ptPrintText(text: String, promise: Promise) {
    printerExecute(text.toByteArray(), "Print text", promise)
  }

  override fun getConstants(): MutableMap<String, Any> =
    hashMapOf(
      "PT_ALIGN_CENTER" to "ALIGN_CENTER",
      "PT_ALIGN_RIGHT" to "ALIGN_RIGHT",
      "PT_ALIGN_LEFT" to "ALIGN_LEFT"
    )

  companion object {
    const val NAME = "PrinterPt220"
    const val PRINTER_SERVICE = "00001101-0000-1000-8000-00805f9b34fb"
    val ALIGN_CENTER = byteArrayOf(27, 97, 1)
    val ALIGN_RIGHT = byteArrayOf(27, 97, 2)
    val ALIGN_LEFT = byteArrayOf(27, 97, 0)
  }

  val printerCommands: HashMap<String, ByteArray> = hashMapOf(
    "ALIGN_CENTER" to ALIGN_CENTER,
    "ALIGN_RIGHT" to ALIGN_RIGHT,
    "ALIGN_LEFT" to ALIGN_LEFT
  )

  @SuppressLint("MissingPermission")
  private class PrinterThread(private val device: BluetoothDevice) : Thread() {
    private var thisSocket: BluetoothSocket? = null

    init {
      var tmp: BluetoothSocket? = null
      try {
        tmp = device.createRfcommSocketToServiceRecord(UUID.fromString(PRINTER_SERVICE))
      } catch (e: IOException) {
      }
      thisSocket = tmp
    }

    override fun run() {
      btAdapter?.cancelDiscovery()

      try {
        thisSocket?.connect()
      } catch (e: IOException) {
        return
      }

      btSocket = thisSocket!!
    }
  }
}
