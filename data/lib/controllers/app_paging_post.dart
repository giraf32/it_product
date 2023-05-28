import 'dart:async';
import 'dart:io';

import 'package:conduit_core/conduit_core.dart';
import 'package:data/utils/app_response.dart';
import 'package:data/utils/app_utils.dart';

import '../models/post.dart';



class AppPagingPost extends ResourceController {
  final ManagedContext managedContext;
  AppPagingPost(this.managedContext);

  @Operation.get('fetchLimit','dateTime')
  Future<Response> getPosts(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path('fetchLimit') int fetchLimit,
    @Bind.path('dateTime') DateTime dateTime
    // @Bind.query('offset') int offset,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qGetPosts = Query<Post>(managedContext)
        ..where((x) => x.author?.id).equalTo(id)
        ..pageBy((x) => x.dueData, QuerySortOrder.descending, boundingValue: dateTime)
        ..fetchLimit = fetchLimit;

      final List<Post> posts = await qGetPosts.fetch();
     // DateTime? lastPost = posts.last.dueData;

     // print('$lastPost testPosts');
      //print('$postFirst testPostsFirst');

      if (posts.isEmpty) return AppResponse.ok(message: 'Посты не найдены');
      return Response.ok(posts);
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка получения постов');
    }
  }

  }