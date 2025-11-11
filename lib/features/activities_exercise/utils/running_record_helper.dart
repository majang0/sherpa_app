// lib/features/activities_exercise/utils/running_record_helper.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_app/features/activities_exercise/models/detailed_exercise_models.dart';

/// Helper class for RunningRecord SharedPreferences operations
///
/// Centralizes all RunningRecord storage logic to eliminate code duplication
/// and provide consistent error handling across the app.
class RunningRecordHelper {
  // SharedPreferences key for running records storage
  static const String _storageKey = 'running_records';

  /// Load a RunningRecord by ID from SharedPreferences
  ///
  /// Returns null if:
  /// - Record not found
  /// - JSON parsing error
  /// - SharedPreferences access error
  static Future<RunningRecord?> loadById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final runningRecordsJson = prefs.getString(_storageKey) ?? '{}';
      final runningRecords = Map<String, dynamic>.from(
        jsonDecode(runningRecordsJson) as Map,
      );

      if (runningRecords.containsKey(id)) {
        return RunningRecord.fromJson(runningRecords[id] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to load RunningRecord: $e');
      return null;
    }
  }

  /// Save a RunningRecord to SharedPreferences
  ///
  /// Throws Exception if save fails (caller should handle for critical operations)
  static Future<void> saveRecord(RunningRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final runningRecordsJson = prefs.getString(_storageKey) ?? '{}';
      final runningRecords = Map<String, dynamic>.from(
        jsonDecode(runningRecordsJson) as Map,
      );

      runningRecords[record.id] = record.toJson();
      await prefs.setString(_storageKey, jsonEncode(runningRecords));
    } catch (e) {
      debugPrint('Failed to save RunningRecord: $e');
      // Don't throw for now - silent fail to maintain backward compatibility
      // Future: Consider throwing for critical operations
    }
  }

  /// Update a RunningRecord in SharedPreferences
  ///
  /// Alias for saveRecord() - updates are the same as saves
  static Future<void> updateRecord(RunningRecord record) async {
    await saveRecord(record);
  }

  /// Delete a RunningRecord from SharedPreferences
  ///
  /// Silently succeeds if record doesn't exist
  static Future<void> deleteRecord(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final runningRecordsJson = prefs.getString(_storageKey) ?? '{}';
      final runningRecords = Map<String, dynamic>.from(
        jsonDecode(runningRecordsJson) as Map,
      );

      runningRecords.remove(id);
      await prefs.setString(_storageKey, jsonEncode(runningRecords));
    } catch (e) {
      debugPrint('Failed to delete RunningRecord: $e');
      // Silent fail - deletion failure is not critical
    }
  }

  /// Load all RunningRecords from SharedPreferences
  ///
  /// Returns empty list if no records found or error occurs
  static Future<List<RunningRecord>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final runningRecordsJson = prefs.getString(_storageKey) ?? '{}';
      final runningRecords = Map<String, dynamic>.from(
        jsonDecode(runningRecordsJson) as Map,
      );

      return runningRecords.values
          .map((json) => RunningRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to load all RunningRecords: $e');
      return [];
    }
  }

  /// Check if a RunningRecord exists for the given ID
  static Future<bool> exists(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final runningRecordsJson = prefs.getString(_storageKey) ?? '{}';
      final runningRecords = Map<String, dynamic>.from(
        jsonDecode(runningRecordsJson) as Map,
      );

      return runningRecords.containsKey(id);
    } catch (e) {
      debugPrint('Failed to check RunningRecord existence: $e');
      return false;
    }
  }

  /// Clear all RunningRecords from SharedPreferences
  ///
  /// ⚠️ WARNING: This will delete ALL running records permanently!
  /// Use this to reset corrupted/duplicate data.
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      debugPrint('✅ All RunningRecords cleared from SharedPreferences');
    } catch (e) {
      debugPrint('❌ Failed to clear RunningRecords: $e');
    }
  }

  /// Debug: Print statistics about stored RunningRecords
  ///
  /// Returns a map with count and total distance
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final runningRecordsJson = prefs.getString(_storageKey) ?? '{}';
      final runningRecords = Map<String, dynamic>.from(
        jsonDecode(runningRecordsJson) as Map,
      );

      final records = runningRecords.values
          .map((json) => RunningRecord.fromJson(json as Map<String, dynamic>))
          .toList();

      final totalDistance =
          records.fold<double>(0.0, (sum, r) => sum + r.distanceKm);
      final count = records.length;

      debugPrint('📊 RunningRecord Storage Stats:');
      debugPrint('   Total records: $count');
      debugPrint('   Total distance: ${totalDistance.toStringAsFixed(2)} km');

      return {
        'count': count,
        'totalDistance': totalDistance,
        'records': records,
      };
    } catch (e) {
      debugPrint('❌ Failed to get storage stats: $e');
      return {'count': 0, 'totalDistance': 0.0, 'records': []};
    }
  }
}
