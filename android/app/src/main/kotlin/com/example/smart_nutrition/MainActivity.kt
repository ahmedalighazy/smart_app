package com.example.smart_nutrition

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.smart_nutrition/pdf"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openPDF" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        try {
                            openPDF(filePath)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("PDF_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openPDF(filePath: String) {
        val file = File(filePath)
        if (!file.exists()) {
            throw Exception("File not found: $filePath")
        }

        val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            FileProvider.getUriForFile(this, "${packageName}.fileprovider", file)
        } else {
            Uri.fromFile(file)
        }

        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/pdf")
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
        }

        try {
            startActivity(intent)
        } catch (e: Exception) {
            throw Exception("No PDF viewer app found: ${e.message}")
        }
    }
}
