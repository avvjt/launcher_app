package com.example.launcher_app

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.WindowManager
import android.widget.Toast
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.util.concurrent.Executor

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.example.launcher_app/launcher"
    private val APP_DATA_CHANNEL = "com.example.launcher_app/app_data"
    private val LOCK_APP_CHANNEL = "com.example.launcher_app/lock_app"

    private lateinit var executor: Executor
    private lateinit var biometricPrompt: BiometricPrompt
    private lateinit var promptInfo: BiometricPrompt.PromptInfo

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

        // Set up MethodChannel for user authentication
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCK_APP_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "authenticateUser") {
                authenticateUser(result)
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

    // Ensure the app hides content in recent apps by applying FLAG_SECURE when moving to background
    override fun onPause() {
        super.onPause()
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }

    override fun onResume() {
        super.onResume()
        // Call Flutter method to authenticate when the app is resumed
        authenticateUser(null)
    }

    private fun authenticateUser(result: MethodChannel.Result?) {
        executor = ContextCompat.getMainExecutor(this)
        biometricPrompt = BiometricPrompt(this, executor, object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                // Authentication succeeded
                Toast.makeText(applicationContext, "Authentication succeeded", Toast.LENGTH_SHORT).show()
                result?.success(null)
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                // Handle error
                Toast.makeText(applicationContext, "Authentication error: $errString", Toast.LENGTH_SHORT).show()
                result?.error("AUTH_ERROR", errString.toString(), null)
            }

            override fun onAuthenticationFailed() {
                // Handle failure
                Toast.makeText(applicationContext, "Authentication failed", Toast.LENGTH_SHORT).show()
                result?.error("AUTH_FAILED", "Authentication failed", null)
            }
        })

        promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Biometric login for my app")
            .setSubtitle("Log in using your biometric credential")
            .setNegativeButtonText("Use account password")
            .build()

        biometricPrompt.authenticate(promptInfo)
    }
}
