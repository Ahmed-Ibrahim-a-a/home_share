import '../models/member.dart';

abstract class MemberRepository {
  Future<void> initialize();
  Future<List<Member>> getAllMembers();
  Future<Member?> getMemberById(String id);
  Future<void> addMember(Member member);
  Future<void> updateMember(Member member);
  Future<void> deleteMember(String id);
}
