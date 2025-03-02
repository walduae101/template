package com.easylife.sajaya

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.content.Intent
import android.util.Log

class MainActivity : FlutterActivity() {
    // Explicitly disable any splash screen behavior
    override fun onCreate(savedInstanceState: Bundle?) {
        // Skip default splash screen logic
        setTheme(android.R.style.Theme_NoTitleBar)
        super.onCreate(savedInstanceState)
        
        // Process the intent that started this activity
        handleIntent(intent)
    }
    
    // Handle new intents (when app is already running)
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }
    
    // Process deep links
    private fun handleIntent(intent: Intent) {
        val action = intent.action
        val data = intent.data
        
        if (Intent.ACTION_VIEW == action && data != null) {
            val scheme = data.scheme
            val host = data.host
            
            Log.d("DeepLink", "Received deep link: $data")
            
            // Handle Apple Sign-In callback
            if (scheme == "sajaya" && host == "apple-login-callback") {
                Log.d("AppleSignIn", "Received Apple Sign-In callback")
                // The app is now in foreground, no additional action needed
            }
        }
    }
} 