import 'package:dtube_togo/bloc/avalonConfig/avalonConfig_bloc_full.dart';
import 'package:dtube_togo/bloc/user/user_response_model.dart';

import 'package:dtube_togo/res/strings/strings.dart';
import 'package:dtube_togo/utils/growInt.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:base58check/base58.dart';

abstract class UserRepository {
  Future<User> getAccountData(
      String apiNode, String username, String applicationUser);
  Future<Map<String, int>> getVP(
      String apiNode, String username, String applicationUser);
  Future<int> getDTC(String apiNode, String username, String applicationUser);
}

class UserRepositoryImpl implements UserRepository {
  @override
  Future<User> getAccountData(
      String apiNode, String username, applicationUser) async {
    var response = await http.get(Uri.parse(apiNode +
        AppStrings.accountDataUrl.replaceAll("##USERNAME", username)));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      User user = ApiResultModel.fromJson(data, applicationUser).user;
      return user;
    } else {
      throw Exception();
    }
  }

  Future<Map<String, int>> getVP(
      String apiNode, String username, String applicationUser) async {
    Map<String, int> currentVT = {
      "v": 0,
      "t": 0,
    };

    int dtcBalance = 0;
    var response = await http.get(Uri.parse(apiNode +
        AppStrings.accountDataUrl.replaceAll("##USERNAME", username)));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      User user = ApiResultModel.fromJson(data, applicationUser).user;
      dtcBalance = user.balance;
      int vp = user.vt!.v;
      int vpTS = user.vt!.t;
      var configResponse =
          await http.get(Uri.parse(apiNode + AppStrings.avalonConfig));
      if (configResponse.statusCode == 200) {
        var configData = json.decode(configResponse.body);
        AvalonConfig conf =
            ApiResultModelAvalonConfig.fromJson(configData).conf;
        int vpGrowth = conf.vtGrowth;
        currentVT = growInt(vp, vpTS, (dtcBalance / vpGrowth).floor(), 0, 0);
      } else {
        throw Exception();
      }
    }
    return currentVT;
  }

  Future<int> getDTC(String apiNode, String username, applicationUser) async {
    int dtcBalance = 0;
    var response = await http.get(Uri.parse(apiNode +
        AppStrings.accountDataUrl.replaceAll("##USERNAME", username)));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      User user = ApiResultModel.fromJson(data, applicationUser).user;
      dtcBalance = user.balance;
    } else {
      throw Exception();
    }

    return dtcBalance;
  }
}
