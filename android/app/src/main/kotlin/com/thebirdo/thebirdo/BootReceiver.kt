// android/app/src/main/kotlin/com/yourpackage/birdo/BootReceiver.kt
package com.yourpackage.birdo

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BirdoBootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Boot completed - rescheduling alarms")

        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_PACKAGE_REPLACED -> {

                try {
                    // Start a service to reschedule alarms
                    val serviceIntent = Intent(context, AlarmRescheduleService::class.java)
                    context.startForegroundService(serviceIntent)

                    Log.i(TAG, "Alarm reschedule service started successfully")

                } catch (e: Exception) {
                    Log.e(TAG, "Failed to start alarm reschedule service", e)
                }
            }
        }
    }
}

// Service to handle alarm rescheduling in background
class AlarmRescheduleService : android.app.Service() {

    companion object {
        private const val TAG = "AlarmRescheduleService"
        private const val NOTIFICATION_ID = 9999
        private const val CHANNEL_ID = "alarm_reschedule"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Starting alarm reschedule service")

        // Start as foreground service
        startForeground(NOTIFICATION_ID, createNotification())

        // Reschedule alarms in background thread
        Thread {
            try {
                rescheduleAlarms()
            } catch (e: Exception) {
                Log.e(TAG, "Error rescheduling alarms", e)
            } finally {
                stopSelf()
            }
        }.start()

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): android.os.IBinder? = null

    private fun createNotificationChannel() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val channel = android.app.NotificationChannel(
                CHANNEL_ID,
                "Alarm Reschedule",
                android.app.NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Rescheduling alarms after device restart"
                enableLights(false)
                enableVibration(false)
                setSound(null, null)
            }

            val notificationManager = getSystemService(android.app.NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): android.app.Notification {
        return if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            android.app.Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            android.app.Notification.Builder(this)
        }.apply {
            setContentTitle("Birdo")
            setContentText("Rescheduling alarms...")
            setSmallIcon(android.R.drawable.ic_dialog_info)
            setOngoing(true)
        }.build()
    }

    private fun rescheduleAlarms() {
        Log.d(TAG, "Starting alarm reschedule process")

        try {
            // Get SharedPreferences to read saved schedules
            val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
            val savedSchedules = prefs.getStringSet("flutter.saved_schedules", emptySet()) ?: emptySet()

            Log.d(TAG, "Found ${savedSchedules.size} saved schedules to reschedule")

            // Here you would implement the actual rescheduling logic
            // This could involve calling your EnhancedBackgroundAlarmManager methods
            // through JNI or by triggering a Flutter method channel call

            // For now, we'll log that we found schedules
            for ((index, schedule) in savedSchedules.withIndex()) {
                Log.d(TAG, "Rescheduling alarm ${index + 1}: $schedule")
                // Implement actual rescheduling here
            }

        } catch (e: Exception) {
            Log.e(TAG, "Failed to reschedule alarms", e)
        }
    }
}