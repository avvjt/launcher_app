package com.example.launcher_app

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.example.launcher_app/launcher"
    private val APP_DATA_CHANNEL = "com.example.launcher_app/app_data"
    private val LOCK_APP_CHANNEL = "com.example.launcher_app/lock_app"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        // Set up MethodChannel for launcher-related methods
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isDefaultLauncher") {
                result.success(isDefaultLauncher())
            } else {
                result.notImplemented()
            }
        }

        // Set up MethodChannel for clearing app data
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_DATA_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "clearAppData") {
                val packageName: String? = call.argument("packageName")
                if (packageName != null) {
                    val cleared = clearAppData(packageName)
                    if (cleared) {
                        result.success(null)
                    } else {
                        result.error("CLEAR_FAILED", "Failed to clear app data", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Package name is required", null)
                }
            } else {
                result.notImplemented()
            }
        }

        // Set up MethodChannel for removing app from recent apps
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCK_APP_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "removeFromRecents") {
                removeAppFromRecents()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    // Function to check if the app is the default launcher
    private fun isDefaultLauncher(): Boolean {
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_HOME)
        val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return resolveInfo?.activityInfo?.packageName == packageName
    }

    // Function to clear app data
    private fun clearAppData(packageName: String): Boolean {
        return try {
            Runtime.getRuntime().exec("pm clear $packageName")
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    // Function to remove the app from recent apps
    private fun removeAppFromRecents() {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        activityManager.appTasks?.forEach { task ->
            if (task.taskInfo.baseActivity?.packageName == packageName) {
                task.finishAndRemoveTask()  // Removes the app from recent apps
            }
        }
    }
}
