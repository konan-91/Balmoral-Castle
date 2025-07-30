package com.balmoralcastle.balmoral_castle

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()


/* REVERTING TO /ASSETS
package com.balmoralcastle.balmoral_castle

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "video_path_channel")
            .setMethodCallHandler { call, result ->
                if (call.method == "getVideoPath") {
                    val fileName = call.argument<String>("name") ?: return@setMethodCallHandler
                    val assetPath = "videos/$fileName.mp4"
                    val file = File(cacheDir, fileName)

                    if (!file.exists()) {
                        assets.open(assetPath).use { input ->
                            FileOutputStream(file).use { output ->
                                input.copyTo(output)
                            }
                        }
                    }

                    result.success(file.absolutePath)
                } else {
                    result.notImplemented()
                }
            }
    }
}
 */
