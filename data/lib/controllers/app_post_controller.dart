import 'dart:async';
import 'dart:io';
import 'package:conduit_core/conduit_core.dart';
import 'package:data/utils/app_response.dart';
import 'package:data/models/post.dart';
import 'package:data/models/author.dart';
import 'package:data/utils/app_utils.dart';

class AppPostController extends ResourceController {
  final ManagedContext managedContext;
 
  AppPostController(this.managedContext);
  

  @Operation.get()
  Future<Response> getPosts(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.query('fetchLimit') int fetchLimit,
    
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qGetPosts = Query<Post>(managedContext)
        ..where((x) => x.author?.id).equalTo(id)
        ..pageBy((x) => x.dueData, QuerySortOrder.descending)
        ..fetchLimit = fetchLimit;

      final List<Post> posts = await qGetPosts.fetch();
     
      if (posts.isEmpty) return AppResponse.ok(message: 'Посты не найдены');
      return Response.ok(posts);
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка получения постов');
    }
  }
   @Operation.get('dateTime')
  Future<Response> getNextPosts(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.query('fetchLimit') int fetchLimit,
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
      DateTime? lastPost = posts.last.dueData;

      print('$lastPost testPosts');
      //print('$postFirst testPostsFirst');

      if (posts.isEmpty) return AppResponse.ok(message: 'Посты не найдены');
      return Response.ok(posts);
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка получения постов');
    }
  }


  @Operation.post()
  Future<Response> creatPost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Post post) async {
    if (post.content == null ||
        post.content?.isEmpty == true ||
        post.name == null ||
        post.name?.isEmpty == true) {
      return AppResponse.badRequest(message: "Поля content и name обязательны");
    }
    try {
      final id = AppUtils.getIdFromHeader(header);
      final author = await managedContext.fetchObjectWithID<Author>(id);
      if (author == null) {
        final qCreateAuthor = Query<Author>(managedContext)..values.id = id;
        await qCreateAuthor.insert();
      }
      final size = post.content?.length ?? 0;
      final qCreatePost = Query<Post>(managedContext)
        ..values.author?.id = id
        ..values.name = post.name
        ..values.dueData = DateTime.now()
        ..values.preContent = post.content?.substring(0, size <= 20 ? size : 20)
        ..values.content = post.content;

      await qCreatePost.insert();
      return AppResponse.ok(message: 'Успешное создание поста');
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка создание поста');
    }
  }

  @Operation.get('id')
  Future<Response> getPost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path('id') int id) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final qGetPost = Query<Post>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..where((x) => x.author?.id).equalTo(currentAuthorId)
        ..returningProperties((x) => [x.name, x.id, x.content]);

      final post = await qGetPost.fetchOne();
      if (post == null) {
        return AppResponse.ok(message: 'пост не найден');
      }

      return AppResponse.ok(
          body: post.backing.contents, message: 'Успешное получение поста');
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка получения поста');
    }
  }

  @Operation.delete('id')
  Future<Response> deletePost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path('id') int id) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);
      if (post == null) {
        return AppResponse.ok(message: 'пост не найден');
      }
      if (post.author?.id != currentAuthorId) {
        return AppResponse.ok(message: 'нет доступа к посту');
      }
      final qDeletePost = Query<Post>(managedContext)
        ..where((x) => x.id).equalTo(id);
      await qDeletePost.delete();

      return AppResponse.ok(message: 'Успешное удоление поста');
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка удоления поста');
    }
  }
}
