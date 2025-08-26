// MainActivity.kt
package com.gedes.cv.generator

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.gedes.cv.generator/file_manager"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "openFileManager" -> {
                    val directoryName = call.argument<String>("directoryName")
                    if (directoryName != null) {
                        openFileManager(directoryName)
                        result.success("File manager opened successfully for $directoryName")
                    } else {
                        result.error("INVALID_ARGUMENT", "Directory name is null", null)
                    }
                }
                "getDocumentsDirectory" -> {
                    try {
                        val documentsDirectory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
                        result.success(documentsDirectory.path)
                    } catch (e: Exception) {
                        result.error("DIRECTORY_ERROR", "Could not get documents directory path: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openFileManager(directoryName: String) {
        try {
            val documentsDirectory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
            val targetDirectory = File(documentsDirectory, directoryName)
            if (!targetDirectory.exists()) {
                targetDirectory.mkdirs()
            }
            val intent = Intent(Intent.ACTION_VIEW)
            val uri = Uri.parse(targetDirectory.path)
            intent.setDataAndType(uri, "*/*")
            startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}