import 'package:conduit_core/conduit_core.dart';
import 'package:data/utils/app_env.dart';
import 'controllers/app_paging_post.dart';
import 'controllers/app_post_controller.dart';
import 'controllers/app_token_controller.dart';
import 'package:conduit_postgresql/conduit_postgresql.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;
  // метод для настройки служб, которые [Контролеры] используют для выполнения своих обязанностях
  @override
  Future prepare() {
    // служат связующим звеном между [Запросом] и конкретной базой данных.
    PersistentStore? persistentStore = _initDatabase();
    ManagedDataModel? dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    // [Запрос] отправляется в базу данных, описанную [постоянное хранилище'persistenStore'].
    //[Запрос] может быть выполнен только в этом контексте, если его тип находится в [модели данных'dataModel'].
    managedContext = ManagedContext(dataModel, persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint {
    final router = Router();
    router
        .route('posts/[:id]')
        .link(() => AppTokenController())!
        .link(() => AppPostController(managedContext));
    router
        .route('posts/next/:fetchLimit/:dateTime')
        .link(() => AppTokenController())!
        .link(() => AppPagingPost(managedContext));

    return router;
  }

  // Для взаимодействия с базой данных PostgreSQL
  PostgreSQLPersistentStore _initDatabase() {
    return PostgreSQLPersistentStore(AppEnv.dbUsername, AppEnv.dbPassword,
        AppEnv.dbHost, int.tryParse(AppEnv.dbPort), AppEnv.dbDatabaseName);
  }
}
