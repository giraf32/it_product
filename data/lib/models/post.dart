import 'package:conduit_core/conduit_core.dart';
import 'author.dart';

class Post extends ManagedObject<_Post> implements _Post {}

class _Post {
  @primaryKey
  int? id;
  @Column(omitByDefault: true)
  String? content;
  @Column(omitByDefault: true)
  String? test;
  String? preContent;
  String? name;
  @Column(indexed: true)
  DateTime? dueData;
  @Relate(#postList, isRequired: true, onDelete: DeleteRule.cascade)
  Author? author;
}
