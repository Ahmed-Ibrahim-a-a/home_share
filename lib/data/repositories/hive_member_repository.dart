import 'package:hive/hive.dart';

import '../../domain/models/member.dart';
import '../../domain/repositories/member_repository.dart';

class HiveMemberRepository implements MemberRepository {
  static const String _boxName = 'members';
  late Box<Member> _box;

  @override
  Future<void> initialize() async {
    _box = await Hive.openBox<Member>(_boxName);
  }

  @override
  Future<List<Member>> getAllMembers() async {
    return _box.values.toList();
  }

  @override
  Future<Member?> getMemberById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> addMember(Member member) async {
    await _box.put(member.id, member);
  }

  @override
  Future<void> updateMember(Member member) async {
    await _box.put(member.id, member);
  }

  @override
  Future<void> deleteMember(String id) async {
    await _box.delete(id);
  }
}
