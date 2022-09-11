import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:soshi/services/dataEngine.dart';

enum TASK {
  ADD_FIRST_FRIEND,
  TOGGLE_SWITCH,
  COMPLETE_SCAN,
  ADD_PERSONAL_LINK,
  CREATE_GROUP,

  ADD_ANY_NEW_FRIEND
}

class PointTask {
  int value;
  bool completed;
  bool repeatable;
  PointTask({@required this.value, @required this.completed, @required bool this.repeatable});
  String serializeString() {
    return jsonEncode({'value': value, 'completed': completed});
  }

  Map serializeDictionary() {
    return {'value': value, 'completed': completed};
  }

  static decode(Map input) {
    // Map decoded = jsonDecode(input);
    return PointTask(value: input['value'], completed: input['completed']);
  }
}

class PointManager {
  Map<TASK, PointTask> pointMap = {
    TASK.ADD_ANY_NEW_FRIEND: PointTask(value: 10, completed: false, repeatable: true),
    TASK.ADD_FIRST_FRIEND: PointTask(value: 10, completed: false, repeatable: false),
    TASK.TOGGLE_SWITCH: PointTask(value: 10, completed: false, repeatable: false),
    TASK.COMPLETE_SCAN: PointTask(value: 10, completed: false, repeatable: false),
    TASK.ADD_PERSONAL_LINK: PointTask(value: 10, completed: false, repeatable: false),
    TASK.CREATE_GROUP: PointTask(value: 10, completed: false, repeatable: false),
  };

  PointManager(Map userData) {
    log("🔢 PointManager Start 🔢");

    Map pm = userData['Point Manager'];

    if (pm != null) {
      pm.forEach((key, value) {
        TASK task = TASK.values.firstWhere((element) => element.toString() == key);
        pointMap[task] = PointTask.decode(value);
      });
    } else {
      log("🔢 PointManager NOT FOUND...using Default 🔢");
    }
  }

  markTaskAsComplete({@required TASK task, @required SoshiUser targetUser}) async {
    try {
      PointTask pt = pointMap[task];
      if (pt.repeatable || !pt.completed) {
        targetUser.soshiPoints = targetUser.soshiPoints + pt.value;
      }
      DataEngine.applyUserChanges(user: targetUser, cloud: true, local: true);
      log("🔢PointManager sucessfully gave points to targetUser🔢");
    } catch (e) {
      log("🔢⚠ PointManager UNABLE to update task status ERROR ⚠🔢");
    }
  }

  clearAllFlags() {
    this.pointMap.forEach((key, value) {
      value.completed = false;
    });
  }

  Map serializeDictionary() {
    Map stringVersion = {};
    pointMap.forEach((key, value) {
      stringVersion[key.toString()] = value.serializeDictionary();
    });
    return stringVersion;
  }

  String serializeString() {
    Map stringVersion = {};
    pointMap.forEach((key, value) {
      stringVersion[key.toString()] = value.serializeDictionary();
    });
    return jsonEncode(stringVersion);
  }
}
