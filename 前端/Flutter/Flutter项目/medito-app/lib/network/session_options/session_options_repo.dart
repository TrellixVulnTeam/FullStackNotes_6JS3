/*This file is part of Medito App.

Medito App is free software: you can redistribute it and/or modify
it under the terms of the Affero GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Medito App is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
Affero GNU General Public License for more details.

You should have received a copy of the Affero GNU General Public License
along with Medito App. If not, see <https://www.gnu.org/licenses/>.*/

import 'package:Medito/network/session_options/background_sounds.dart';
import 'package:Medito/network/session_options/session_opts.dart';
import 'package:Medito/utils/navigation.dart';
import 'package:Medito/viewmodel/auth.dart';
import 'package:Medito/viewmodel/http_get.dart';

class session_optionsRepository {
  var ext = 'items/sessions/';
  var dailiesExt = 'items/dailies/';
  var bgSoundsUrl = '${baseUrl}items/background_sounds';
  var parameters =
      '?fields=*,author.body,audio.file.id,audio.file.voice,audio.file.length';
  var screen;

  session_optionsRepository({this.screen});

  Future<SessionData> fetchOptions(String id, bool skipCache) async {
    var url;

    if (screen == Screen.daily) {
      url = baseUrl + dailiesExt + id + parameters;
    } else {
      url = baseUrl + ext + id + parameters;
    }

    final response = await httpGet(url, skipCache: skipCache);

    return session_optionsResponse.fromJson(response).data;
  }

  Future<BackgroundSoundsResponse> fetchBackgroundSounds(bool skipCache) async {
    final response = await httpGet(bgSoundsUrl, skipCache: skipCache);
    return BackgroundSoundsResponse.fromJson(response);
  }

}
