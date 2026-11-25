// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openidMeta = const VerificationMeta('openid');
  @override
  late final GeneratedColumn<String> openid = GeneratedColumn<String>(
    'openid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _unionidMeta = const VerificationMeta(
    'unionid',
  );
  @override
  late final GeneratedColumn<String> unionid = GeneratedColumn<String>(
    'unionid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loginTypeMeta = const VerificationMeta(
    'loginType',
  );
  @override
  late final GeneratedColumn<String> loginType = GeneratedColumn<String>(
    'login_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('guest'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    openid,
    unionid,
    email,
    passwordHash,
    nickname,
    avatarUrl,
    loginType,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('openid')) {
      context.handle(
        _openidMeta,
        openid.isAcceptableOrUnknown(data['openid']!, _openidMeta),
      );
    }
    if (data.containsKey('unionid')) {
      context.handle(
        _unionidMeta,
        unionid.isAcceptableOrUnknown(data['unionid']!, _unionidMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('login_type')) {
      context.handle(
        _loginTypeMeta,
        loginType.isAcceptableOrUnknown(data['login_type']!, _loginTypeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      openid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}openid'],
      ),
      unionid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unionid'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      ),
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      loginType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}login_type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String? openid;
  final String? unionid;
  final String? email;
  final String? passwordHash;
  final String nickname;
  final String? avatarUrl;
  final String loginType;
  final String createdAt;
  final String updatedAt;
  const User({
    required this.id,
    this.openid,
    this.unionid,
    this.email,
    this.passwordHash,
    required this.nickname,
    this.avatarUrl,
    required this.loginType,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || openid != null) {
      map['openid'] = Variable<String>(openid);
    }
    if (!nullToAbsent || unionid != null) {
      map['unionid'] = Variable<String>(unionid);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || passwordHash != null) {
      map['password_hash'] = Variable<String>(passwordHash);
    }
    map['nickname'] = Variable<String>(nickname);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['login_type'] = Variable<String>(loginType);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      openid: openid == null && nullToAbsent
          ? const Value.absent()
          : Value(openid),
      unionid: unionid == null && nullToAbsent
          ? const Value.absent()
          : Value(unionid),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      passwordHash: passwordHash == null && nullToAbsent
          ? const Value.absent()
          : Value(passwordHash),
      nickname: Value(nickname),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      loginType: Value(loginType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      openid: serializer.fromJson<String?>(json['openid']),
      unionid: serializer.fromJson<String?>(json['unionid']),
      email: serializer.fromJson<String?>(json['email']),
      passwordHash: serializer.fromJson<String?>(json['passwordHash']),
      nickname: serializer.fromJson<String>(json['nickname']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      loginType: serializer.fromJson<String>(json['loginType']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'openid': serializer.toJson<String?>(openid),
      'unionid': serializer.toJson<String?>(unionid),
      'email': serializer.toJson<String?>(email),
      'passwordHash': serializer.toJson<String?>(passwordHash),
      'nickname': serializer.toJson<String>(nickname),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'loginType': serializer.toJson<String>(loginType),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  User copyWith({
    String? id,
    Value<String?> openid = const Value.absent(),
    Value<String?> unionid = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> passwordHash = const Value.absent(),
    String? nickname,
    Value<String?> avatarUrl = const Value.absent(),
    String? loginType,
    String? createdAt,
    String? updatedAt,
  }) => User(
    id: id ?? this.id,
    openid: openid.present ? openid.value : this.openid,
    unionid: unionid.present ? unionid.value : this.unionid,
    email: email.present ? email.value : this.email,
    passwordHash: passwordHash.present ? passwordHash.value : this.passwordHash,
    nickname: nickname ?? this.nickname,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    loginType: loginType ?? this.loginType,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      openid: data.openid.present ? data.openid.value : this.openid,
      unionid: data.unionid.present ? data.unionid.value : this.unionid,
      email: data.email.present ? data.email.value : this.email,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      loginType: data.loginType.present ? data.loginType.value : this.loginType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('openid: $openid, ')
          ..write('unionid: $unionid, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('nickname: $nickname, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('loginType: $loginType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    openid,
    unionid,
    email,
    passwordHash,
    nickname,
    avatarUrl,
    loginType,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.openid == this.openid &&
          other.unionid == this.unionid &&
          other.email == this.email &&
          other.passwordHash == this.passwordHash &&
          other.nickname == this.nickname &&
          other.avatarUrl == this.avatarUrl &&
          other.loginType == this.loginType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String?> openid;
  final Value<String?> unionid;
  final Value<String?> email;
  final Value<String?> passwordHash;
  final Value<String> nickname;
  final Value<String?> avatarUrl;
  final Value<String> loginType;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.openid = const Value.absent(),
    this.unionid = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.loginType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    this.openid = const Value.absent(),
    this.unionid = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.loginType = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? openid,
    Expression<String>? unionid,
    Expression<String>? email,
    Expression<String>? passwordHash,
    Expression<String>? nickname,
    Expression<String>? avatarUrl,
    Expression<String>? loginType,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (openid != null) 'openid': openid,
      if (unionid != null) 'unionid': unionid,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (nickname != null) 'nickname': nickname,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (loginType != null) 'login_type': loginType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String?>? openid,
    Value<String?>? unionid,
    Value<String?>? email,
    Value<String?>? passwordHash,
    Value<String>? nickname,
    Value<String?>? avatarUrl,
    Value<String>? loginType,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      openid: openid ?? this.openid,
      unionid: unionid ?? this.unionid,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      loginType: loginType ?? this.loginType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (openid.present) {
      map['openid'] = Variable<String>(openid.value);
    }
    if (unionid.present) {
      map['unionid'] = Variable<String>(unionid.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (loginType.present) {
      map['login_type'] = Variable<String>(loginType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('openid: $openid, ')
          ..write('unionid: $unionid, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('nickname: $nickname, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('loginType: $loginType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalsTable extends SavingsGoals
    with TableInfo<$SavingsGoalsTable, SavingsGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountCentsMeta = const VerificationMeta(
    'targetAmountCents',
  );
  @override
  late final GeneratedColumn<int> targetAmountCents = GeneratedColumn<int>(
    'target_amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<String> deadline = GeneratedColumn<String>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _themeColorMeta = const VerificationMeta(
    'themeColor',
  );
  @override
  late final GeneratedColumn<String> themeColor = GeneratedColumn<String>(
    'theme_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#1F6F5C'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    targetAmountCents,
    deadline,
    icon,
    themeColor,
    note,
    status,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount_cents')) {
      context.handle(
        _targetAmountCentsMeta,
        targetAmountCents.isAcceptableOrUnknown(
          data['target_amount_cents']!,
          _targetAmountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountCentsMeta);
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('theme_color')) {
      context.handle(
        _themeColorMeta,
        themeColor.isAcceptableOrUnknown(data['theme_color']!, _themeColorMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetAmountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_amount_cents'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deadline'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      themeColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_color'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $SavingsGoalsTable createAlias(String alias) {
    return $SavingsGoalsTable(attachedDatabase, alias);
  }
}

class SavingsGoal extends DataClass implements Insertable<SavingsGoal> {
  final String id;
  final String userId;
  final String name;
  final int targetAmountCents;
  final String? deadline;
  final String icon;
  final String themeColor;
  final String? note;
  final String status;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  const SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmountCents,
    this.deadline,
    required this.icon,
    required this.themeColor,
    this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['target_amount_cents'] = Variable<int>(targetAmountCents);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<String>(deadline);
    }
    map['icon'] = Variable<String>(icon);
    map['theme_color'] = Variable<String>(themeColor);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  SavingsGoalsCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      targetAmountCents: Value(targetAmountCents),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      icon: Value(icon),
      themeColor: Value(themeColor),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory SavingsGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoal(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      targetAmountCents: serializer.fromJson<int>(json['targetAmountCents']),
      deadline: serializer.fromJson<String?>(json['deadline']),
      icon: serializer.fromJson<String>(json['icon']),
      themeColor: serializer.fromJson<String>(json['themeColor']),
      note: serializer.fromJson<String?>(json['note']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'targetAmountCents': serializer.toJson<int>(targetAmountCents),
      'deadline': serializer.toJson<String?>(deadline),
      'icon': serializer.toJson<String>(icon),
      'themeColor': serializer.toJson<String>(themeColor),
      'note': serializer.toJson<String?>(note),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  SavingsGoal copyWith({
    String? id,
    String? userId,
    String? name,
    int? targetAmountCents,
    Value<String?> deadline = const Value.absent(),
    String? icon,
    String? themeColor,
    Value<String?> note = const Value.absent(),
    String? status,
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
  }) => SavingsGoal(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    targetAmountCents: targetAmountCents ?? this.targetAmountCents,
    deadline: deadline.present ? deadline.value : this.deadline,
    icon: icon ?? this.icon,
    themeColor: themeColor ?? this.themeColor,
    note: note.present ? note.value : this.note,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  SavingsGoal copyWithCompanion(SavingsGoalsCompanion data) {
    return SavingsGoal(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      targetAmountCents: data.targetAmountCents.present
          ? data.targetAmountCents.value
          : this.targetAmountCents,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      icon: data.icon.present ? data.icon.value : this.icon,
      themeColor: data.themeColor.present
          ? data.themeColor.value
          : this.themeColor,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoal(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('targetAmountCents: $targetAmountCents, ')
          ..write('deadline: $deadline, ')
          ..write('icon: $icon, ')
          ..write('themeColor: $themeColor, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    targetAmountCents,
    deadline,
    icon,
    themeColor,
    note,
    status,
    createdAt,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoal &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.targetAmountCents == this.targetAmountCents &&
          other.deadline == this.deadline &&
          other.icon == this.icon &&
          other.themeColor == this.themeColor &&
          other.note == this.note &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class SavingsGoalsCompanion extends UpdateCompanion<SavingsGoal> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<int> targetAmountCents;
  final Value<String?> deadline;
  final Value<String> icon;
  final Value<String> themeColor;
  final Value<String?> note;
  final Value<String> status;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const SavingsGoalsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmountCents = const Value.absent(),
    this.deadline = const Value.absent(),
    this.icon = const Value.absent(),
    this.themeColor = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsGoalsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required int targetAmountCents,
    this.deadline = const Value.absent(),
    this.icon = const Value.absent(),
    this.themeColor = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       targetAmountCents = Value(targetAmountCents),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SavingsGoal> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<int>? targetAmountCents,
    Expression<String>? deadline,
    Expression<String>? icon,
    Expression<String>? themeColor,
    Expression<String>? note,
    Expression<String>? status,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (targetAmountCents != null) 'target_amount_cents': targetAmountCents,
      if (deadline != null) 'deadline': deadline,
      if (icon != null) 'icon': icon,
      if (themeColor != null) 'theme_color': themeColor,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsGoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<int>? targetAmountCents,
    Value<String?>? deadline,
    Value<String>? icon,
    Value<String>? themeColor,
    Value<String?>? note,
    Value<String>? status,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return SavingsGoalsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmountCents: targetAmountCents ?? this.targetAmountCents,
      deadline: deadline ?? this.deadline,
      icon: icon ?? this.icon,
      themeColor: themeColor ?? this.themeColor,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmountCents.present) {
      map['target_amount_cents'] = Variable<int>(targetAmountCents.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<String>(deadline.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (themeColor.present) {
      map['theme_color'] = Variable<String>(themeColor.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('targetAmountCents: $targetAmountCents, ')
          ..write('deadline: $deadline, ')
          ..write('icon: $icon, ')
          ..write('themeColor: $themeColor, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalLedgerBindingsTable extends GoalLedgerBindings
    with TableInfo<$GoalLedgerBindingsTable, GoalLedgerBinding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalLedgerBindingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  @override
  late final GeneratedColumn<String> ledgerId = GeneratedColumn<String>(
    'ledger_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    goalId,
    ledgerId,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_ledger_bindings';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalLedgerBinding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ledgerIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {goalId, ledgerId};
  @override
  GoalLedgerBinding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalLedgerBinding(
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_id'],
      )!,
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $GoalLedgerBindingsTable createAlias(String alias) {
    return $GoalLedgerBindingsTable(attachedDatabase, alias);
  }
}

class GoalLedgerBinding extends DataClass
    implements Insertable<GoalLedgerBinding> {
  final String goalId;
  final String ledgerId;
  final String userId;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  const GoalLedgerBinding({
    required this.goalId,
    required this.ledgerId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['goal_id'] = Variable<String>(goalId);
    map['ledger_id'] = Variable<String>(ledgerId);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  GoalLedgerBindingsCompanion toCompanion(bool nullToAbsent) {
    return GoalLedgerBindingsCompanion(
      goalId: Value(goalId),
      ledgerId: Value(ledgerId),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory GoalLedgerBinding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalLedgerBinding(
      goalId: serializer.fromJson<String>(json['goalId']),
      ledgerId: serializer.fromJson<String>(json['ledgerId']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'goalId': serializer.toJson<String>(goalId),
      'ledgerId': serializer.toJson<String>(ledgerId),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  GoalLedgerBinding copyWith({
    String? goalId,
    String? ledgerId,
    String? userId,
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
  }) => GoalLedgerBinding(
    goalId: goalId ?? this.goalId,
    ledgerId: ledgerId ?? this.ledgerId,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  GoalLedgerBinding copyWithCompanion(GoalLedgerBindingsCompanion data) {
    return GoalLedgerBinding(
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalLedgerBinding(')
          ..write('goalId: $goalId, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(goalId, ledgerId, userId, createdAt, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalLedgerBinding &&
          other.goalId == this.goalId &&
          other.ledgerId == this.ledgerId &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class GoalLedgerBindingsCompanion extends UpdateCompanion<GoalLedgerBinding> {
  final Value<String> goalId;
  final Value<String> ledgerId;
  final Value<String> userId;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const GoalLedgerBindingsCompanion({
    this.goalId = const Value.absent(),
    this.ledgerId = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalLedgerBindingsCompanion.insert({
    required String goalId,
    required String ledgerId,
    this.userId = const Value.absent(),
    required String createdAt,
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : goalId = Value(goalId),
       ledgerId = Value(ledgerId),
       createdAt = Value(createdAt);
  static Insertable<GoalLedgerBinding> custom({
    Expression<String>? goalId,
    Expression<String>? ledgerId,
    Expression<String>? userId,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (goalId != null) 'goal_id': goalId,
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalLedgerBindingsCompanion copyWith({
    Value<String>? goalId,
    Value<String>? ledgerId,
    Value<String>? userId,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return GoalLedgerBindingsCompanion(
      goalId: goalId ?? this.goalId,
      ledgerId: ledgerId ?? this.ledgerId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (ledgerId.present) {
      map['ledger_id'] = Variable<String>(ledgerId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalLedgerBindingsCompanion(')
          ..write('goalId: $goalId, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalMilestonesTable extends GoalMilestones
    with TableInfo<$GoalMilestonesTable, GoalMilestone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalMilestonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thresholdPctMeta = const VerificationMeta(
    'thresholdPct',
  );
  @override
  late final GeneratedColumn<int> thresholdPct = GeneratedColumn<int>(
    'threshold_pct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _firstReachedDateMeta = const VerificationMeta(
    'firstReachedDate',
  );
  @override
  late final GeneratedColumn<String> firstReachedDate = GeneratedColumn<String>(
    'first_reached_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    goalId,
    thresholdPct,
    userId,
    firstReachedDate,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_milestones';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalMilestone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('threshold_pct')) {
      context.handle(
        _thresholdPctMeta,
        thresholdPct.isAcceptableOrUnknown(
          data['threshold_pct']!,
          _thresholdPctMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thresholdPctMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('first_reached_date')) {
      context.handle(
        _firstReachedDateMeta,
        firstReachedDate.isAcceptableOrUnknown(
          data['first_reached_date']!,
          _firstReachedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstReachedDateMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {goalId, thresholdPct};
  @override
  GoalMilestone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalMilestone(
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_id'],
      )!,
      thresholdPct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}threshold_pct'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      firstReachedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_reached_date'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $GoalMilestonesTable createAlias(String alias) {
    return $GoalMilestonesTable(attachedDatabase, alias);
  }
}

class GoalMilestone extends DataClass implements Insertable<GoalMilestone> {
  final String goalId;
  final int thresholdPct;
  final String userId;
  final String firstReachedDate;
  final String updatedAt;
  final bool isDeleted;
  const GoalMilestone({
    required this.goalId,
    required this.thresholdPct,
    required this.userId,
    required this.firstReachedDate,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['goal_id'] = Variable<String>(goalId);
    map['threshold_pct'] = Variable<int>(thresholdPct);
    map['user_id'] = Variable<String>(userId);
    map['first_reached_date'] = Variable<String>(firstReachedDate);
    map['updated_at'] = Variable<String>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  GoalMilestonesCompanion toCompanion(bool nullToAbsent) {
    return GoalMilestonesCompanion(
      goalId: Value(goalId),
      thresholdPct: Value(thresholdPct),
      userId: Value(userId),
      firstReachedDate: Value(firstReachedDate),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory GoalMilestone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalMilestone(
      goalId: serializer.fromJson<String>(json['goalId']),
      thresholdPct: serializer.fromJson<int>(json['thresholdPct']),
      userId: serializer.fromJson<String>(json['userId']),
      firstReachedDate: serializer.fromJson<String>(json['firstReachedDate']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'goalId': serializer.toJson<String>(goalId),
      'thresholdPct': serializer.toJson<int>(thresholdPct),
      'userId': serializer.toJson<String>(userId),
      'firstReachedDate': serializer.toJson<String>(firstReachedDate),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  GoalMilestone copyWith({
    String? goalId,
    int? thresholdPct,
    String? userId,
    String? firstReachedDate,
    String? updatedAt,
    bool? isDeleted,
  }) => GoalMilestone(
    goalId: goalId ?? this.goalId,
    thresholdPct: thresholdPct ?? this.thresholdPct,
    userId: userId ?? this.userId,
    firstReachedDate: firstReachedDate ?? this.firstReachedDate,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  GoalMilestone copyWithCompanion(GoalMilestonesCompanion data) {
    return GoalMilestone(
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      thresholdPct: data.thresholdPct.present
          ? data.thresholdPct.value
          : this.thresholdPct,
      userId: data.userId.present ? data.userId.value : this.userId,
      firstReachedDate: data.firstReachedDate.present
          ? data.firstReachedDate.value
          : this.firstReachedDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalMilestone(')
          ..write('goalId: $goalId, ')
          ..write('thresholdPct: $thresholdPct, ')
          ..write('userId: $userId, ')
          ..write('firstReachedDate: $firstReachedDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    goalId,
    thresholdPct,
    userId,
    firstReachedDate,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalMilestone &&
          other.goalId == this.goalId &&
          other.thresholdPct == this.thresholdPct &&
          other.userId == this.userId &&
          other.firstReachedDate == this.firstReachedDate &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class GoalMilestonesCompanion extends UpdateCompanion<GoalMilestone> {
  final Value<String> goalId;
  final Value<int> thresholdPct;
  final Value<String> userId;
  final Value<String> firstReachedDate;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const GoalMilestonesCompanion({
    this.goalId = const Value.absent(),
    this.thresholdPct = const Value.absent(),
    this.userId = const Value.absent(),
    this.firstReachedDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalMilestonesCompanion.insert({
    required String goalId,
    required int thresholdPct,
    this.userId = const Value.absent(),
    required String firstReachedDate,
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : goalId = Value(goalId),
       thresholdPct = Value(thresholdPct),
       firstReachedDate = Value(firstReachedDate);
  static Insertable<GoalMilestone> custom({
    Expression<String>? goalId,
    Expression<int>? thresholdPct,
    Expression<String>? userId,
    Expression<String>? firstReachedDate,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (goalId != null) 'goal_id': goalId,
      if (thresholdPct != null) 'threshold_pct': thresholdPct,
      if (userId != null) 'user_id': userId,
      if (firstReachedDate != null) 'first_reached_date': firstReachedDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalMilestonesCompanion copyWith({
    Value<String>? goalId,
    Value<int>? thresholdPct,
    Value<String>? userId,
    Value<String>? firstReachedDate,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return GoalMilestonesCompanion(
      goalId: goalId ?? this.goalId,
      thresholdPct: thresholdPct ?? this.thresholdPct,
      userId: userId ?? this.userId,
      firstReachedDate: firstReachedDate ?? this.firstReachedDate,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (thresholdPct.present) {
      map['threshold_pct'] = Variable<int>(thresholdPct.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (firstReachedDate.present) {
      map['first_reached_date'] = Variable<String>(firstReachedDate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalMilestonesCompanion(')
          ..write('goalId: $goalId, ')
          ..write('thresholdPct: $thresholdPct, ')
          ..write('userId: $userId, ')
          ..write('firstReachedDate: $firstReachedDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgersTable extends Ledgers with TableInfo<$LedgersTable, Ledger> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#1F6F5C'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    icon,
    color,
    sortOrder,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledgers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ledger> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ledger map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ledger(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $LedgersTable createAlias(String alias) {
    return $LedgersTable(attachedDatabase, alias);
  }
}

class Ledger extends DataClass implements Insertable<Ledger> {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final String color;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  const Ledger({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  LedgersCompanion toCompanion(bool nullToAbsent) {
    return LedgersCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory Ledger.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ledger(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Ledger copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    String? color,
    int? sortOrder,
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
  }) => Ledger(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Ledger copyWithCompanion(LedgersCompanion data) {
    return Ledger(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ledger(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    icon,
    color,
    sortOrder,
    createdAt,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ledger &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class LedgersCompanion extends UpdateCompanion<Ledger> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> color;
  final Value<int> sortOrder;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const LedgersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgersCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Ledger> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgersCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? icon,
    Value<String>? color,
    Value<int>? sortOrder,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return LedgersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BillsTable extends Bills with TableInfo<$BillsTable, Bill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  @override
  late final GeneratedColumn<String> ledgerId = GeneratedColumn<String>(
    'ledger_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billDateMeta = const VerificationMeta(
    'billDate',
  );
  @override
  late final GeneratedColumn<String> billDate = GeneratedColumn<String>(
    'bill_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ledgerId,
    categoryId,
    type,
    amountCents,
    billDate,
    note,
    source,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bill> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ledgerIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('bill_date')) {
      context.handle(
        _billDateMeta,
        billDate.isAcceptableOrUnknown(data['bill_date']!, _billDateMeta),
      );
    } else if (isInserting) {
      context.missing(_billDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bill(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      billDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $BillsTable createAlias(String alias) {
    return $BillsTable(attachedDatabase, alias);
  }
}

class Bill extends DataClass implements Insertable<Bill> {
  final String id;
  final String ledgerId;
  final String categoryId;
  final String type;
  final int amountCents;
  final String billDate;
  final String? note;
  final String source;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  const Bill({
    required this.id,
    required this.ledgerId,
    required this.categoryId,
    required this.type,
    required this.amountCents,
    required this.billDate,
    this.note,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ledger_id'] = Variable<String>(ledgerId);
    map['category_id'] = Variable<String>(categoryId);
    map['type'] = Variable<String>(type);
    map['amount_cents'] = Variable<int>(amountCents);
    map['bill_date'] = Variable<String>(billDate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  BillsCompanion toCompanion(bool nullToAbsent) {
    return BillsCompanion(
      id: Value(id),
      ledgerId: Value(ledgerId),
      categoryId: Value(categoryId),
      type: Value(type),
      amountCents: Value(amountCents),
      billDate: Value(billDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory Bill.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bill(
      id: serializer.fromJson<String>(json['id']),
      ledgerId: serializer.fromJson<String>(json['ledgerId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      type: serializer.fromJson<String>(json['type']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      billDate: serializer.fromJson<String>(json['billDate']),
      note: serializer.fromJson<String?>(json['note']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ledgerId': serializer.toJson<String>(ledgerId),
      'categoryId': serializer.toJson<String>(categoryId),
      'type': serializer.toJson<String>(type),
      'amountCents': serializer.toJson<int>(amountCents),
      'billDate': serializer.toJson<String>(billDate),
      'note': serializer.toJson<String?>(note),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Bill copyWith({
    String? id,
    String? ledgerId,
    String? categoryId,
    String? type,
    int? amountCents,
    String? billDate,
    Value<String?> note = const Value.absent(),
    String? source,
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
  }) => Bill(
    id: id ?? this.id,
    ledgerId: ledgerId ?? this.ledgerId,
    categoryId: categoryId ?? this.categoryId,
    type: type ?? this.type,
    amountCents: amountCents ?? this.amountCents,
    billDate: billDate ?? this.billDate,
    note: note.present ? note.value : this.note,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Bill copyWithCompanion(BillsCompanion data) {
    return Bill(
      id: data.id.present ? data.id.value : this.id,
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      type: data.type.present ? data.type.value : this.type,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      billDate: data.billDate.present ? data.billDate.value : this.billDate,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bill(')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('categoryId: $categoryId, ')
          ..write('type: $type, ')
          ..write('amountCents: $amountCents, ')
          ..write('billDate: $billDate, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ledgerId,
    categoryId,
    type,
    amountCents,
    billDate,
    note,
    source,
    createdAt,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bill &&
          other.id == this.id &&
          other.ledgerId == this.ledgerId &&
          other.categoryId == this.categoryId &&
          other.type == this.type &&
          other.amountCents == this.amountCents &&
          other.billDate == this.billDate &&
          other.note == this.note &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class BillsCompanion extends UpdateCompanion<Bill> {
  final Value<String> id;
  final Value<String> ledgerId;
  final Value<String> categoryId;
  final Value<String> type;
  final Value<int> amountCents;
  final Value<String> billDate;
  final Value<String?> note;
  final Value<String> source;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const BillsCompanion({
    this.id = const Value.absent(),
    this.ledgerId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.type = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.billDate = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillsCompanion.insert({
    required String id,
    required String ledgerId,
    required String categoryId,
    required String type,
    required int amountCents,
    required String billDate,
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ledgerId = Value(ledgerId),
       categoryId = Value(categoryId),
       type = Value(type),
       amountCents = Value(amountCents),
       billDate = Value(billDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Bill> custom({
    Expression<String>? id,
    Expression<String>? ledgerId,
    Expression<String>? categoryId,
    Expression<String>? type,
    Expression<int>? amountCents,
    Expression<String>? billDate,
    Expression<String>? note,
    Expression<String>? source,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (categoryId != null) 'category_id': categoryId,
      if (type != null) 'type': type,
      if (amountCents != null) 'amount_cents': amountCents,
      if (billDate != null) 'bill_date': billDate,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillsCompanion copyWith({
    Value<String>? id,
    Value<String>? ledgerId,
    Value<String>? categoryId,
    Value<String>? type,
    Value<int>? amountCents,
    Value<String>? billDate,
    Value<String?>? note,
    Value<String>? source,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return BillsCompanion(
      id: id ?? this.id,
      ledgerId: ledgerId ?? this.ledgerId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amountCents: amountCents ?? this.amountCents,
      billDate: billDate ?? this.billDate,
      note: note ?? this.note,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ledgerId.present) {
      map['ledger_id'] = Variable<String>(ledgerId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (billDate.present) {
      map['bill_date'] = Variable<String>(billDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillsCompanion(')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('categoryId: $categoryId, ')
          ..write('type: $type, ')
          ..write('amountCents: $amountCents, ')
          ..write('billDate: $billDate, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#C6A15B'),
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    type,
    icon,
    color,
    isCustom,
    sortOrder,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String userId;
  final String name;
  final String type;
  final String icon;
  final String color;
  final bool isCustom;
  final int sortOrder;
  final String updatedAt;
  final bool isDeleted;
  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isCustom,
    required this.sortOrder,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    map['is_custom'] = Variable<bool>(isCustom);
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at'] = Variable<String>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      type: Value(type),
      icon: Value(icon),
      color: Value(color),
      isCustom: Value(isCustom),
      sortOrder: Value(sortOrder),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'isCustom': serializer.toJson<bool>(isCustom),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? icon,
    String? color,
    bool? isCustom,
    int? sortOrder,
    String? updatedAt,
    bool? isDeleted,
  }) => Category(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    type: type ?? this.type,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    isCustom: isCustom ?? this.isCustom,
    sortOrder: sortOrder ?? this.sortOrder,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isCustom: $isCustom, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    type,
    icon,
    color,
    isCustom,
    sortOrder,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.type == this.type &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isCustom == this.isCustom &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> type;
  final Value<String> icon;
  final Value<String> color;
  final Value<bool> isCustom;
  final Value<int> sortOrder;
  final Value<String> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required String type,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       type = Value(type);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<bool>? isCustom,
    Expression<int>? sortOrder,
    Expression<String>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isCustom != null) 'is_custom': isCustom,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? type,
    Value<String>? icon,
    Value<String>? color,
    Value<bool>? isCustom,
    Value<int>? sortOrder,
    Value<String>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isCustom: isCustom ?? this.isCustom,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isCustom: $isCustom, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LegacyDepositArchiveTable extends LegacyDepositArchive
    with TableInfo<$LegacyDepositArchiveTable, LegacyDepositArchiveData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LegacyDepositArchiveTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceBillIdMeta = const VerificationMeta(
    'sourceBillId',
  );
  @override
  late final GeneratedColumn<String> sourceBillId = GeneratedColumn<String>(
    'source_bill_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<String> archivedAt = GeneratedColumn<String>(
    'archived_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    goalId,
    amountCents,
    sourceBillId,
    note,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'legacy_deposit_archive';
  @override
  VerificationContext validateIntegrity(
    Insertable<LegacyDepositArchiveData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('source_bill_id')) {
      context.handle(
        _sourceBillIdMeta,
        sourceBillId.isAcceptableOrUnknown(
          data['source_bill_id']!,
          _sourceBillIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_archivedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LegacyDepositArchiveData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LegacyDepositArchiveData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      sourceBillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_bill_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archived_at'],
      )!,
    );
  }

  @override
  $LegacyDepositArchiveTable createAlias(String alias) {
    return $LegacyDepositArchiveTable(attachedDatabase, alias);
  }
}

class LegacyDepositArchiveData extends DataClass
    implements Insertable<LegacyDepositArchiveData> {
  final String id;
  final String userId;
  final String goalId;
  final int amountCents;
  final String? sourceBillId;
  final String? note;
  final String archivedAt;
  const LegacyDepositArchiveData({
    required this.id,
    required this.userId,
    required this.goalId,
    required this.amountCents,
    this.sourceBillId,
    this.note,
    required this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['goal_id'] = Variable<String>(goalId);
    map['amount_cents'] = Variable<int>(amountCents);
    if (!nullToAbsent || sourceBillId != null) {
      map['source_bill_id'] = Variable<String>(sourceBillId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['archived_at'] = Variable<String>(archivedAt);
    return map;
  }

  LegacyDepositArchiveCompanion toCompanion(bool nullToAbsent) {
    return LegacyDepositArchiveCompanion(
      id: Value(id),
      userId: Value(userId),
      goalId: Value(goalId),
      amountCents: Value(amountCents),
      sourceBillId: sourceBillId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceBillId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      archivedAt: Value(archivedAt),
    );
  }

  factory LegacyDepositArchiveData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LegacyDepositArchiveData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      goalId: serializer.fromJson<String>(json['goalId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      sourceBillId: serializer.fromJson<String?>(json['sourceBillId']),
      note: serializer.fromJson<String?>(json['note']),
      archivedAt: serializer.fromJson<String>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'goalId': serializer.toJson<String>(goalId),
      'amountCents': serializer.toJson<int>(amountCents),
      'sourceBillId': serializer.toJson<String?>(sourceBillId),
      'note': serializer.toJson<String?>(note),
      'archivedAt': serializer.toJson<String>(archivedAt),
    };
  }

  LegacyDepositArchiveData copyWith({
    String? id,
    String? userId,
    String? goalId,
    int? amountCents,
    Value<String?> sourceBillId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? archivedAt,
  }) => LegacyDepositArchiveData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    goalId: goalId ?? this.goalId,
    amountCents: amountCents ?? this.amountCents,
    sourceBillId: sourceBillId.present ? sourceBillId.value : this.sourceBillId,
    note: note.present ? note.value : this.note,
    archivedAt: archivedAt ?? this.archivedAt,
  );
  LegacyDepositArchiveData copyWithCompanion(
    LegacyDepositArchiveCompanion data,
  ) {
    return LegacyDepositArchiveData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      sourceBillId: data.sourceBillId.present
          ? data.sourceBillId.value
          : this.sourceBillId,
      note: data.note.present ? data.note.value : this.note,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LegacyDepositArchiveData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('goalId: $goalId, ')
          ..write('amountCents: $amountCents, ')
          ..write('sourceBillId: $sourceBillId, ')
          ..write('note: $note, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    goalId,
    amountCents,
    sourceBillId,
    note,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LegacyDepositArchiveData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.goalId == this.goalId &&
          other.amountCents == this.amountCents &&
          other.sourceBillId == this.sourceBillId &&
          other.note == this.note &&
          other.archivedAt == this.archivedAt);
}

class LegacyDepositArchiveCompanion
    extends UpdateCompanion<LegacyDepositArchiveData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> goalId;
  final Value<int> amountCents;
  final Value<String?> sourceBillId;
  final Value<String?> note;
  final Value<String> archivedAt;
  final Value<int> rowid;
  const LegacyDepositArchiveCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.goalId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.sourceBillId = const Value.absent(),
    this.note = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LegacyDepositArchiveCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String goalId,
    required int amountCents,
    this.sourceBillId = const Value.absent(),
    this.note = const Value.absent(),
    required String archivedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       goalId = Value(goalId),
       amountCents = Value(amountCents),
       archivedAt = Value(archivedAt);
  static Insertable<LegacyDepositArchiveData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? goalId,
    Expression<int>? amountCents,
    Expression<String>? sourceBillId,
    Expression<String>? note,
    Expression<String>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (goalId != null) 'goal_id': goalId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (sourceBillId != null) 'source_bill_id': sourceBillId,
      if (note != null) 'note': note,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LegacyDepositArchiveCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? goalId,
    Value<int>? amountCents,
    Value<String?>? sourceBillId,
    Value<String?>? note,
    Value<String>? archivedAt,
    Value<int>? rowid,
  }) {
    return LegacyDepositArchiveCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalId: goalId ?? this.goalId,
      amountCents: amountCents ?? this.amountCents,
      sourceBillId: sourceBillId ?? this.sourceBillId,
      note: note ?? this.note,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (sourceBillId.present) {
      map['source_bill_id'] = Variable<String>(sourceBillId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<String>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LegacyDepositArchiveCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('goalId: $goalId, ')
          ..write('amountCents: $amountCents, ')
          ..write('sourceBillId: $sourceBillId, ')
          ..write('note: $note, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiAnalysisReportsTable extends AiAnalysisReports
    with TableInfo<$AiAnalysisReportsTable, AiAnalysisReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiAnalysisReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopePeriodTypeMeta = const VerificationMeta(
    'scopePeriodType',
  );
  @override
  late final GeneratedColumn<String> scopePeriodType = GeneratedColumn<String>(
    'scope_period_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopePeriodLabelMeta = const VerificationMeta(
    'scopePeriodLabel',
  );
  @override
  late final GeneratedColumn<String> scopePeriodLabel = GeneratedColumn<String>(
    'scope_period_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeLedgerKeyMeta = const VerificationMeta(
    'scopeLedgerKey',
  );
  @override
  late final GeneratedColumn<String> scopeLedgerKey = GeneratedColumn<String>(
    'scope_ledger_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeAnchorDateMeta = const VerificationMeta(
    'scopeAnchorDate',
  );
  @override
  late final GeneratedColumn<String> scopeAnchorDate = GeneratedColumn<String>(
    'scope_anchor_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportJsonMeta = const VerificationMeta(
    'reportJson',
  );
  @override
  late final GeneratedColumn<String> reportJson = GeneratedColumn<String>(
    'report_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataVersionMeta = const VerificationMeta(
    'dataVersion',
  );
  @override
  late final GeneratedColumn<String> dataVersion = GeneratedColumn<String>(
    'data_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<String> expiresAt = GeneratedColumn<String>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isStaleMeta = const VerificationMeta(
    'isStale',
  );
  @override
  late final GeneratedColumn<bool> isStale = GeneratedColumn<bool>(
    'is_stale',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_stale" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _goalKeyMeta = const VerificationMeta(
    'goalKey',
  );
  @override
  late final GeneratedColumn<String> goalKey = GeneratedColumn<String>(
    'goal_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consentVersionMeta = const VerificationMeta(
    'consentVersion',
  );
  @override
  late final GeneratedColumn<String> consentVersion = GeneratedColumn<String>(
    'consent_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scopePeriodType,
    scopePeriodLabel,
    scopeLedgerKey,
    scopeAnchorDate,
    reportJson,
    dataVersion,
    createdAt,
    updatedAt,
    expiresAt,
    isStale,
    goalKey,
    modelId,
    consentVersion,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_analysis_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiAnalysisReport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scope_period_type')) {
      context.handle(
        _scopePeriodTypeMeta,
        scopePeriodType.isAcceptableOrUnknown(
          data['scope_period_type']!,
          _scopePeriodTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scopePeriodTypeMeta);
    }
    if (data.containsKey('scope_period_label')) {
      context.handle(
        _scopePeriodLabelMeta,
        scopePeriodLabel.isAcceptableOrUnknown(
          data['scope_period_label']!,
          _scopePeriodLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scopePeriodLabelMeta);
    }
    if (data.containsKey('scope_ledger_key')) {
      context.handle(
        _scopeLedgerKeyMeta,
        scopeLedgerKey.isAcceptableOrUnknown(
          data['scope_ledger_key']!,
          _scopeLedgerKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scopeLedgerKeyMeta);
    }
    if (data.containsKey('scope_anchor_date')) {
      context.handle(
        _scopeAnchorDateMeta,
        scopeAnchorDate.isAcceptableOrUnknown(
          data['scope_anchor_date']!,
          _scopeAnchorDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scopeAnchorDateMeta);
    }
    if (data.containsKey('report_json')) {
      context.handle(
        _reportJsonMeta,
        reportJson.isAcceptableOrUnknown(data['report_json']!, _reportJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_reportJsonMeta);
    }
    if (data.containsKey('data_version')) {
      context.handle(
        _dataVersionMeta,
        dataVersion.isAcceptableOrUnknown(
          data['data_version']!,
          _dataVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataVersionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('is_stale')) {
      context.handle(
        _isStaleMeta,
        isStale.isAcceptableOrUnknown(data['is_stale']!, _isStaleMeta),
      );
    }
    if (data.containsKey('goal_key')) {
      context.handle(
        _goalKeyMeta,
        goalKey.isAcceptableOrUnknown(data['goal_key']!, _goalKeyMeta),
      );
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('consent_version')) {
      context.handle(
        _consentVersionMeta,
        consentVersion.isAcceptableOrUnknown(
          data['consent_version']!,
          _consentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_consentVersionMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiAnalysisReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiAnalysisReport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scopePeriodType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_period_type'],
      )!,
      scopePeriodLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_period_label'],
      )!,
      scopeLedgerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_ledger_key'],
      )!,
      scopeAnchorDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_anchor_date'],
      )!,
      reportJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_json'],
      )!,
      dataVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expires_at'],
      )!,
      isStale: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_stale'],
      )!,
      goalKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_key'],
      ),
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      consentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consent_version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $AiAnalysisReportsTable createAlias(String alias) {
    return $AiAnalysisReportsTable(attachedDatabase, alias);
  }
}

class AiAnalysisReport extends DataClass
    implements Insertable<AiAnalysisReport> {
  final String id;
  final String scopePeriodType;
  final String scopePeriodLabel;
  final String scopeLedgerKey;
  final String scopeAnchorDate;
  final String reportJson;
  final String dataVersion;
  final String createdAt;
  final String updatedAt;
  final String expiresAt;
  final bool isStale;
  final String? goalKey;
  final String modelId;
  final String consentVersion;
  final bool isDeleted;
  const AiAnalysisReport({
    required this.id,
    required this.scopePeriodType,
    required this.scopePeriodLabel,
    required this.scopeLedgerKey,
    required this.scopeAnchorDate,
    required this.reportJson,
    required this.dataVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    required this.isStale,
    this.goalKey,
    required this.modelId,
    required this.consentVersion,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scope_period_type'] = Variable<String>(scopePeriodType);
    map['scope_period_label'] = Variable<String>(scopePeriodLabel);
    map['scope_ledger_key'] = Variable<String>(scopeLedgerKey);
    map['scope_anchor_date'] = Variable<String>(scopeAnchorDate);
    map['report_json'] = Variable<String>(reportJson);
    map['data_version'] = Variable<String>(dataVersion);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['expires_at'] = Variable<String>(expiresAt);
    map['is_stale'] = Variable<bool>(isStale);
    if (!nullToAbsent || goalKey != null) {
      map['goal_key'] = Variable<String>(goalKey);
    }
    map['model_id'] = Variable<String>(modelId);
    map['consent_version'] = Variable<String>(consentVersion);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  AiAnalysisReportsCompanion toCompanion(bool nullToAbsent) {
    return AiAnalysisReportsCompanion(
      id: Value(id),
      scopePeriodType: Value(scopePeriodType),
      scopePeriodLabel: Value(scopePeriodLabel),
      scopeLedgerKey: Value(scopeLedgerKey),
      scopeAnchorDate: Value(scopeAnchorDate),
      reportJson: Value(reportJson),
      dataVersion: Value(dataVersion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      expiresAt: Value(expiresAt),
      isStale: Value(isStale),
      goalKey: goalKey == null && nullToAbsent
          ? const Value.absent()
          : Value(goalKey),
      modelId: Value(modelId),
      consentVersion: Value(consentVersion),
      isDeleted: Value(isDeleted),
    );
  }

  factory AiAnalysisReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiAnalysisReport(
      id: serializer.fromJson<String>(json['id']),
      scopePeriodType: serializer.fromJson<String>(json['scopePeriodType']),
      scopePeriodLabel: serializer.fromJson<String>(json['scopePeriodLabel']),
      scopeLedgerKey: serializer.fromJson<String>(json['scopeLedgerKey']),
      scopeAnchorDate: serializer.fromJson<String>(json['scopeAnchorDate']),
      reportJson: serializer.fromJson<String>(json['reportJson']),
      dataVersion: serializer.fromJson<String>(json['dataVersion']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      expiresAt: serializer.fromJson<String>(json['expiresAt']),
      isStale: serializer.fromJson<bool>(json['isStale']),
      goalKey: serializer.fromJson<String?>(json['goalKey']),
      modelId: serializer.fromJson<String>(json['modelId']),
      consentVersion: serializer.fromJson<String>(json['consentVersion']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scopePeriodType': serializer.toJson<String>(scopePeriodType),
      'scopePeriodLabel': serializer.toJson<String>(scopePeriodLabel),
      'scopeLedgerKey': serializer.toJson<String>(scopeLedgerKey),
      'scopeAnchorDate': serializer.toJson<String>(scopeAnchorDate),
      'reportJson': serializer.toJson<String>(reportJson),
      'dataVersion': serializer.toJson<String>(dataVersion),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'expiresAt': serializer.toJson<String>(expiresAt),
      'isStale': serializer.toJson<bool>(isStale),
      'goalKey': serializer.toJson<String?>(goalKey),
      'modelId': serializer.toJson<String>(modelId),
      'consentVersion': serializer.toJson<String>(consentVersion),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  AiAnalysisReport copyWith({
    String? id,
    String? scopePeriodType,
    String? scopePeriodLabel,
    String? scopeLedgerKey,
    String? scopeAnchorDate,
    String? reportJson,
    String? dataVersion,
    String? createdAt,
    String? updatedAt,
    String? expiresAt,
    bool? isStale,
    Value<String?> goalKey = const Value.absent(),
    String? modelId,
    String? consentVersion,
    bool? isDeleted,
  }) => AiAnalysisReport(
    id: id ?? this.id,
    scopePeriodType: scopePeriodType ?? this.scopePeriodType,
    scopePeriodLabel: scopePeriodLabel ?? this.scopePeriodLabel,
    scopeLedgerKey: scopeLedgerKey ?? this.scopeLedgerKey,
    scopeAnchorDate: scopeAnchorDate ?? this.scopeAnchorDate,
    reportJson: reportJson ?? this.reportJson,
    dataVersion: dataVersion ?? this.dataVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    isStale: isStale ?? this.isStale,
    goalKey: goalKey.present ? goalKey.value : this.goalKey,
    modelId: modelId ?? this.modelId,
    consentVersion: consentVersion ?? this.consentVersion,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  AiAnalysisReport copyWithCompanion(AiAnalysisReportsCompanion data) {
    return AiAnalysisReport(
      id: data.id.present ? data.id.value : this.id,
      scopePeriodType: data.scopePeriodType.present
          ? data.scopePeriodType.value
          : this.scopePeriodType,
      scopePeriodLabel: data.scopePeriodLabel.present
          ? data.scopePeriodLabel.value
          : this.scopePeriodLabel,
      scopeLedgerKey: data.scopeLedgerKey.present
          ? data.scopeLedgerKey.value
          : this.scopeLedgerKey,
      scopeAnchorDate: data.scopeAnchorDate.present
          ? data.scopeAnchorDate.value
          : this.scopeAnchorDate,
      reportJson: data.reportJson.present
          ? data.reportJson.value
          : this.reportJson,
      dataVersion: data.dataVersion.present
          ? data.dataVersion.value
          : this.dataVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      isStale: data.isStale.present ? data.isStale.value : this.isStale,
      goalKey: data.goalKey.present ? data.goalKey.value : this.goalKey,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      consentVersion: data.consentVersion.present
          ? data.consentVersion.value
          : this.consentVersion,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiAnalysisReport(')
          ..write('id: $id, ')
          ..write('scopePeriodType: $scopePeriodType, ')
          ..write('scopePeriodLabel: $scopePeriodLabel, ')
          ..write('scopeLedgerKey: $scopeLedgerKey, ')
          ..write('scopeAnchorDate: $scopeAnchorDate, ')
          ..write('reportJson: $reportJson, ')
          ..write('dataVersion: $dataVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isStale: $isStale, ')
          ..write('goalKey: $goalKey, ')
          ..write('modelId: $modelId, ')
          ..write('consentVersion: $consentVersion, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scopePeriodType,
    scopePeriodLabel,
    scopeLedgerKey,
    scopeAnchorDate,
    reportJson,
    dataVersion,
    createdAt,
    updatedAt,
    expiresAt,
    isStale,
    goalKey,
    modelId,
    consentVersion,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiAnalysisReport &&
          other.id == this.id &&
          other.scopePeriodType == this.scopePeriodType &&
          other.scopePeriodLabel == this.scopePeriodLabel &&
          other.scopeLedgerKey == this.scopeLedgerKey &&
          other.scopeAnchorDate == this.scopeAnchorDate &&
          other.reportJson == this.reportJson &&
          other.dataVersion == this.dataVersion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.expiresAt == this.expiresAt &&
          other.isStale == this.isStale &&
          other.goalKey == this.goalKey &&
          other.modelId == this.modelId &&
          other.consentVersion == this.consentVersion &&
          other.isDeleted == this.isDeleted);
}

class AiAnalysisReportsCompanion extends UpdateCompanion<AiAnalysisReport> {
  final Value<String> id;
  final Value<String> scopePeriodType;
  final Value<String> scopePeriodLabel;
  final Value<String> scopeLedgerKey;
  final Value<String> scopeAnchorDate;
  final Value<String> reportJson;
  final Value<String> dataVersion;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> expiresAt;
  final Value<bool> isStale;
  final Value<String?> goalKey;
  final Value<String> modelId;
  final Value<String> consentVersion;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const AiAnalysisReportsCompanion({
    this.id = const Value.absent(),
    this.scopePeriodType = const Value.absent(),
    this.scopePeriodLabel = const Value.absent(),
    this.scopeLedgerKey = const Value.absent(),
    this.scopeAnchorDate = const Value.absent(),
    this.reportJson = const Value.absent(),
    this.dataVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.isStale = const Value.absent(),
    this.goalKey = const Value.absent(),
    this.modelId = const Value.absent(),
    this.consentVersion = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiAnalysisReportsCompanion.insert({
    required String id,
    required String scopePeriodType,
    required String scopePeriodLabel,
    required String scopeLedgerKey,
    required String scopeAnchorDate,
    required String reportJson,
    required String dataVersion,
    required String createdAt,
    this.updatedAt = const Value.absent(),
    required String expiresAt,
    this.isStale = const Value.absent(),
    this.goalKey = const Value.absent(),
    required String modelId,
    required String consentVersion,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scopePeriodType = Value(scopePeriodType),
       scopePeriodLabel = Value(scopePeriodLabel),
       scopeLedgerKey = Value(scopeLedgerKey),
       scopeAnchorDate = Value(scopeAnchorDate),
       reportJson = Value(reportJson),
       dataVersion = Value(dataVersion),
       createdAt = Value(createdAt),
       expiresAt = Value(expiresAt),
       modelId = Value(modelId),
       consentVersion = Value(consentVersion);
  static Insertable<AiAnalysisReport> custom({
    Expression<String>? id,
    Expression<String>? scopePeriodType,
    Expression<String>? scopePeriodLabel,
    Expression<String>? scopeLedgerKey,
    Expression<String>? scopeAnchorDate,
    Expression<String>? reportJson,
    Expression<String>? dataVersion,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? expiresAt,
    Expression<bool>? isStale,
    Expression<String>? goalKey,
    Expression<String>? modelId,
    Expression<String>? consentVersion,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scopePeriodType != null) 'scope_period_type': scopePeriodType,
      if (scopePeriodLabel != null) 'scope_period_label': scopePeriodLabel,
      if (scopeLedgerKey != null) 'scope_ledger_key': scopeLedgerKey,
      if (scopeAnchorDate != null) 'scope_anchor_date': scopeAnchorDate,
      if (reportJson != null) 'report_json': reportJson,
      if (dataVersion != null) 'data_version': dataVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (isStale != null) 'is_stale': isStale,
      if (goalKey != null) 'goal_key': goalKey,
      if (modelId != null) 'model_id': modelId,
      if (consentVersion != null) 'consent_version': consentVersion,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiAnalysisReportsCompanion copyWith({
    Value<String>? id,
    Value<String>? scopePeriodType,
    Value<String>? scopePeriodLabel,
    Value<String>? scopeLedgerKey,
    Value<String>? scopeAnchorDate,
    Value<String>? reportJson,
    Value<String>? dataVersion,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? expiresAt,
    Value<bool>? isStale,
    Value<String?>? goalKey,
    Value<String>? modelId,
    Value<String>? consentVersion,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return AiAnalysisReportsCompanion(
      id: id ?? this.id,
      scopePeriodType: scopePeriodType ?? this.scopePeriodType,
      scopePeriodLabel: scopePeriodLabel ?? this.scopePeriodLabel,
      scopeLedgerKey: scopeLedgerKey ?? this.scopeLedgerKey,
      scopeAnchorDate: scopeAnchorDate ?? this.scopeAnchorDate,
      reportJson: reportJson ?? this.reportJson,
      dataVersion: dataVersion ?? this.dataVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isStale: isStale ?? this.isStale,
      goalKey: goalKey ?? this.goalKey,
      modelId: modelId ?? this.modelId,
      consentVersion: consentVersion ?? this.consentVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scopePeriodType.present) {
      map['scope_period_type'] = Variable<String>(scopePeriodType.value);
    }
    if (scopePeriodLabel.present) {
      map['scope_period_label'] = Variable<String>(scopePeriodLabel.value);
    }
    if (scopeLedgerKey.present) {
      map['scope_ledger_key'] = Variable<String>(scopeLedgerKey.value);
    }
    if (scopeAnchorDate.present) {
      map['scope_anchor_date'] = Variable<String>(scopeAnchorDate.value);
    }
    if (reportJson.present) {
      map['report_json'] = Variable<String>(reportJson.value);
    }
    if (dataVersion.present) {
      map['data_version'] = Variable<String>(dataVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<String>(expiresAt.value);
    }
    if (isStale.present) {
      map['is_stale'] = Variable<bool>(isStale.value);
    }
    if (goalKey.present) {
      map['goal_key'] = Variable<String>(goalKey.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (consentVersion.present) {
      map['consent_version'] = Variable<String>(consentVersion.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiAnalysisReportsCompanion(')
          ..write('id: $id, ')
          ..write('scopePeriodType: $scopePeriodType, ')
          ..write('scopePeriodLabel: $scopePeriodLabel, ')
          ..write('scopeLedgerKey: $scopeLedgerKey, ')
          ..write('scopeAnchorDate: $scopeAnchorDate, ')
          ..write('reportJson: $reportJson, ')
          ..write('dataVersion: $dataVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isStale: $isStale, ')
          ..write('goalKey: $goalKey, ')
          ..write('modelId: $modelId, ')
          ..write('consentVersion: $consentVersion, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPullSyncedAtMeta = const VerificationMeta(
    'lastPullSyncedAt',
  );
  @override
  late final GeneratedColumn<int> lastPullSyncedAt = GeneratedColumn<int>(
    'last_pull_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPushAtMeta = const VerificationMeta(
    'lastPushAt',
  );
  @override
  late final GeneratedColumn<String> lastPushAt = GeneratedColumn<String>(
    'last_push_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lastPullSyncedAt,
    lastPushAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('last_pull_synced_at')) {
      context.handle(
        _lastPullSyncedAtMeta,
        lastPullSyncedAt.isAcceptableOrUnknown(
          data['last_pull_synced_at']!,
          _lastPullSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_push_at')) {
      context.handle(
        _lastPushAtMeta,
        lastPushAt.isAcceptableOrUnknown(
          data['last_push_at']!,
          _lastPushAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lastPullSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_pull_synced_at'],
      )!,
      lastPushAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_push_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncState extends DataClass implements Insertable<SyncState> {
  /// 固定 '__global__'（单行水位）。
  final String id;
  final int lastPullSyncedAt;
  final String lastPushAt;
  final String? lastError;
  const SyncState({
    required this.id,
    required this.lastPullSyncedAt,
    required this.lastPushAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['last_pull_synced_at'] = Variable<int>(lastPullSyncedAt);
    map['last_push_at'] = Variable<String>(lastPushAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      id: Value(id),
      lastPullSyncedAt: Value(lastPullSyncedAt),
      lastPushAt: Value(lastPushAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncState(
      id: serializer.fromJson<String>(json['id']),
      lastPullSyncedAt: serializer.fromJson<int>(json['lastPullSyncedAt']),
      lastPushAt: serializer.fromJson<String>(json['lastPushAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lastPullSyncedAt': serializer.toJson<int>(lastPullSyncedAt),
      'lastPushAt': serializer.toJson<String>(lastPushAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncState copyWith({
    String? id,
    int? lastPullSyncedAt,
    String? lastPushAt,
    Value<String?> lastError = const Value.absent(),
  }) => SyncState(
    id: id ?? this.id,
    lastPullSyncedAt: lastPullSyncedAt ?? this.lastPullSyncedAt,
    lastPushAt: lastPushAt ?? this.lastPushAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncState copyWithCompanion(SyncStatesCompanion data) {
    return SyncState(
      id: data.id.present ? data.id.value : this.id,
      lastPullSyncedAt: data.lastPullSyncedAt.present
          ? data.lastPullSyncedAt.value
          : this.lastPullSyncedAt,
      lastPushAt: data.lastPushAt.present
          ? data.lastPushAt.value
          : this.lastPushAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncState(')
          ..write('id: $id, ')
          ..write('lastPullSyncedAt: $lastPullSyncedAt, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastPullSyncedAt, lastPushAt, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncState &&
          other.id == this.id &&
          other.lastPullSyncedAt == this.lastPullSyncedAt &&
          other.lastPushAt == this.lastPushAt &&
          other.lastError == this.lastError);
}

class SyncStatesCompanion extends UpdateCompanion<SyncState> {
  final Value<String> id;
  final Value<int> lastPullSyncedAt;
  final Value<String> lastPushAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.id = const Value.absent(),
    this.lastPullSyncedAt = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    required String id,
    this.lastPullSyncedAt = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<SyncState> custom({
    Expression<String>? id,
    Expression<int>? lastPullSyncedAt,
    Expression<String>? lastPushAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastPullSyncedAt != null) 'last_pull_synced_at': lastPullSyncedAt,
      if (lastPushAt != null) 'last_push_at': lastPushAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesCompanion copyWith({
    Value<String>? id,
    Value<int>? lastPullSyncedAt,
    Value<String>? lastPushAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncStatesCompanion(
      id: id ?? this.id,
      lastPullSyncedAt: lastPullSyncedAt ?? this.lastPullSyncedAt,
      lastPushAt: lastPushAt ?? this.lastPushAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lastPullSyncedAt.present) {
      map['last_pull_synced_at'] = Variable<int>(lastPullSyncedAt.value);
    }
    if (lastPushAt.present) {
      map['last_push_at'] = Variable<String>(lastPushAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('id: $id, ')
          ..write('lastPullSyncedAt: $lastPullSyncedAt, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $SavingsGoalsTable savingsGoals = $SavingsGoalsTable(this);
  late final $GoalLedgerBindingsTable goalLedgerBindings =
      $GoalLedgerBindingsTable(this);
  late final $GoalMilestonesTable goalMilestones = $GoalMilestonesTable(this);
  late final $LedgersTable ledgers = $LedgersTable(this);
  late final $BillsTable bills = $BillsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $LegacyDepositArchiveTable legacyDepositArchive =
      $LegacyDepositArchiveTable(this);
  late final $AiAnalysisReportsTable aiAnalysisReports =
      $AiAnalysisReportsTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final GoalDao goalDao = GoalDao(this as AppDatabase);
  late final LedgerDao ledgerDao = LedgerDao(this as AppDatabase);
  late final BillDao billDao = BillDao(this as AppDatabase);
  late final CategoryDao categoryDao = CategoryDao(this as AppDatabase);
  late final BalanceDao balanceDao = BalanceDao(this as AppDatabase);
  late final AnalysisReportDao analysisReportDao = AnalysisReportDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    savingsGoals,
    goalLedgerBindings,
    goalMilestones,
    ledgers,
    bills,
    categories,
    legacyDepositArchive,
    aiAnalysisReports,
    syncStates,
  ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  Value<String?> openid,
  Value<String?> unionid,
  Value<String?> email,
  Value<String?> passwordHash,
  Value<String> nickname,
  Value<String?> avatarUrl,
  Value<String> loginType,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String?> openid,
  Value<String?> unionid,
  Value<String?> email,
  Value<String?> passwordHash,
  Value<String> nickname,
  Value<String?> avatarUrl,
  Value<String> loginType,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openid => $composableBuilder(
    column: $table.openid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unionid => $composableBuilder(
    column: $table.unionid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loginType => $composableBuilder(
    column: $table.loginType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openid => $composableBuilder(
    column: $table.openid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unionid => $composableBuilder(
    column: $table.unionid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loginType => $composableBuilder(
    column: $table.loginType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get openid =>
      $composableBuilder(column: $table.openid, builder: (column) => column);

  GeneratedColumn<String> get unionid =>
      $composableBuilder(column: $table.unionid, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get loginType =>
      $composableBuilder(column: $table.loginType, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> openid = const Value.absent(),
                Value<String?> unionid = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> passwordHash = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> loginType = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                openid: openid,
                unionid: unionid,
                email: email,
                passwordHash: passwordHash,
                nickname: nickname,
                avatarUrl: avatarUrl,
                loginType: loginType,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> openid = const Value.absent(),
                Value<String?> unionid = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> passwordHash = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> loginType = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                openid: openid,
                unionid: unionid,
                email: email,
                passwordHash: passwordHash,
                nickname: nickname,
                avatarUrl: avatarUrl,
                loginType: loginType,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, User>(table),
                  BaseReferences<_$AppDatabase, $UsersTable, User>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$SavingsGoalsTableCreateCompanionBuilder =
    SavingsGoalsCompanion Function({
      required String id,
      required String userId,
      required String name,
      required int targetAmountCents,
      Value<String?> deadline,
      Value<String> icon,
      Value<String> themeColor,
      Value<String?> note,
      Value<String> status,
      required String createdAt,
      required String updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$SavingsGoalsTableUpdateCompanionBuilder =
    SavingsGoalsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<int> targetAmountCents,
      Value<String?> deadline,
      Value<String> icon,
      Value<String> themeColor,
      Value<String?> note,
      Value<String> status,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$SavingsGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetAmountCents => $composableBuilder(
    column: $table.targetAmountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeColor => $composableBuilder(
    column: $table.themeColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavingsGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetAmountCents => $composableBuilder(
    column: $table.targetAmountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeColor => $composableBuilder(
    column: $table.themeColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingsGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get targetAmountCents => $composableBuilder(
    column: $table.targetAmountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get themeColor => $composableBuilder(
    column: $table.themeColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$SavingsGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsGoalsTable,
          SavingsGoal,
          $$SavingsGoalsTableFilterComposer,
          $$SavingsGoalsTableOrderingComposer,
          $$SavingsGoalsTableAnnotationComposer,
          $$SavingsGoalsTableCreateCompanionBuilder,
          $$SavingsGoalsTableUpdateCompanionBuilder,
          (
            SavingsGoal,
            BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoal>,
          ),
          SavingsGoal,
          PrefetchHooks Function()
        > {
  $$SavingsGoalsTableTableManager(_$AppDatabase db, $SavingsGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> targetAmountCents = const Value.absent(),
                Value<String?> deadline = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> themeColor = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion(
                id: id,
                userId: userId,
                name: name,
                targetAmountCents: targetAmountCents,
                deadline: deadline,
                icon: icon,
                themeColor: themeColor,
                note: note,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                required int targetAmountCents,
                Value<String?> deadline = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> themeColor = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                targetAmountCents: targetAmountCents,
                deadline: deadline,
                icon: icon,
                themeColor: themeColor,
                note: note,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SavingsGoalsTable, SavingsGoal>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SavingsGoalsTable,
                    SavingsGoal
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavingsGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsGoalsTable,
      SavingsGoal,
      $$SavingsGoalsTableFilterComposer,
      $$SavingsGoalsTableOrderingComposer,
      $$SavingsGoalsTableAnnotationComposer,
      $$SavingsGoalsTableCreateCompanionBuilder,
      $$SavingsGoalsTableUpdateCompanionBuilder,
      (
        SavingsGoal,
        BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoal>,
      ),
      SavingsGoal,
      PrefetchHooks Function()
    >;
typedef $$GoalLedgerBindingsTableCreateCompanionBuilder =
    GoalLedgerBindingsCompanion Function({
      required String goalId,
      required String ledgerId,
      Value<String> userId,
      required String createdAt,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$GoalLedgerBindingsTableUpdateCompanionBuilder =
    GoalLedgerBindingsCompanion Function({
      Value<String> goalId,
      Value<String> ledgerId,
      Value<String> userId,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$GoalLedgerBindingsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalLedgerBindingsTable> {
  $$GoalLedgerBindingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalLedgerBindingsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalLedgerBindingsTable> {
  $$GoalLedgerBindingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalLedgerBindingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalLedgerBindingsTable> {
  $$GoalLedgerBindingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<String> get ledgerId =>
      $composableBuilder(column: $table.ledgerId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$GoalLedgerBindingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalLedgerBindingsTable,
          GoalLedgerBinding,
          $$GoalLedgerBindingsTableFilterComposer,
          $$GoalLedgerBindingsTableOrderingComposer,
          $$GoalLedgerBindingsTableAnnotationComposer,
          $$GoalLedgerBindingsTableCreateCompanionBuilder,
          $$GoalLedgerBindingsTableUpdateCompanionBuilder,
          (
            GoalLedgerBinding,
            BaseReferences<
              _$AppDatabase,
              $GoalLedgerBindingsTable,
              GoalLedgerBinding
            >,
          ),
          GoalLedgerBinding,
          PrefetchHooks Function()
        > {
  $$GoalLedgerBindingsTableTableManager(
    _$AppDatabase db,
    $GoalLedgerBindingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalLedgerBindingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalLedgerBindingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalLedgerBindingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> goalId = const Value.absent(),
                Value<String> ledgerId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalLedgerBindingsCompanion(
                goalId: goalId,
                ledgerId: ledgerId,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String goalId,
                required String ledgerId,
                Value<String> userId = const Value.absent(),
                required String createdAt,
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalLedgerBindingsCompanion.insert(
                goalId: goalId,
                ledgerId: ledgerId,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalLedgerBindingsTable, GoalLedgerBinding>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $GoalLedgerBindingsTable,
                    GoalLedgerBinding
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalLedgerBindingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalLedgerBindingsTable,
      GoalLedgerBinding,
      $$GoalLedgerBindingsTableFilterComposer,
      $$GoalLedgerBindingsTableOrderingComposer,
      $$GoalLedgerBindingsTableAnnotationComposer,
      $$GoalLedgerBindingsTableCreateCompanionBuilder,
      $$GoalLedgerBindingsTableUpdateCompanionBuilder,
      (
        GoalLedgerBinding,
        BaseReferences<
          _$AppDatabase,
          $GoalLedgerBindingsTable,
          GoalLedgerBinding
        >,
      ),
      GoalLedgerBinding,
      PrefetchHooks Function()
    >;
typedef $$GoalMilestonesTableCreateCompanionBuilder =
    GoalMilestonesCompanion Function({
      required String goalId,
      required int thresholdPct,
      Value<String> userId,
      required String firstReachedDate,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$GoalMilestonesTableUpdateCompanionBuilder =
    GoalMilestonesCompanion Function({
      Value<String> goalId,
      Value<int> thresholdPct,
      Value<String> userId,
      Value<String> firstReachedDate,
      Value<String> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$GoalMilestonesTableFilterComposer
    extends Composer<_$AppDatabase, $GoalMilestonesTable> {
  $$GoalMilestonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get thresholdPct => $composableBuilder(
    column: $table.thresholdPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstReachedDate => $composableBuilder(
    column: $table.firstReachedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalMilestonesTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalMilestonesTable> {
  $$GoalMilestonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get thresholdPct => $composableBuilder(
    column: $table.thresholdPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstReachedDate => $composableBuilder(
    column: $table.firstReachedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalMilestonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalMilestonesTable> {
  $$GoalMilestonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<int> get thresholdPct => $composableBuilder(
    column: $table.thresholdPct,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get firstReachedDate => $composableBuilder(
    column: $table.firstReachedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$GoalMilestonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalMilestonesTable,
          GoalMilestone,
          $$GoalMilestonesTableFilterComposer,
          $$GoalMilestonesTableOrderingComposer,
          $$GoalMilestonesTableAnnotationComposer,
          $$GoalMilestonesTableCreateCompanionBuilder,
          $$GoalMilestonesTableUpdateCompanionBuilder,
          (
            GoalMilestone,
            BaseReferences<_$AppDatabase, $GoalMilestonesTable, GoalMilestone>,
          ),
          GoalMilestone,
          PrefetchHooks Function()
        > {
  $$GoalMilestonesTableTableManager(
    _$AppDatabase db,
    $GoalMilestonesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalMilestonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalMilestonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalMilestonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> goalId = const Value.absent(),
                Value<int> thresholdPct = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> firstReachedDate = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalMilestonesCompanion(
                goalId: goalId,
                thresholdPct: thresholdPct,
                userId: userId,
                firstReachedDate: firstReachedDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String goalId,
                required int thresholdPct,
                Value<String> userId = const Value.absent(),
                required String firstReachedDate,
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalMilestonesCompanion.insert(
                goalId: goalId,
                thresholdPct: thresholdPct,
                userId: userId,
                firstReachedDate: firstReachedDate,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalMilestonesTable, GoalMilestone>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $GoalMilestonesTable,
                    GoalMilestone
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalMilestonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalMilestonesTable,
      GoalMilestone,
      $$GoalMilestonesTableFilterComposer,
      $$GoalMilestonesTableOrderingComposer,
      $$GoalMilestonesTableAnnotationComposer,
      $$GoalMilestonesTableCreateCompanionBuilder,
      $$GoalMilestonesTableUpdateCompanionBuilder,
      (
        GoalMilestone,
        BaseReferences<_$AppDatabase, $GoalMilestonesTable, GoalMilestone>,
      ),
      GoalMilestone,
      PrefetchHooks Function()
    >;
typedef $$LedgersTableCreateCompanionBuilder = LedgersCompanion Function({
  required String id,
  required String userId,
  required String name,
  Value<String> icon,
  Value<String> color,
  Value<int> sortOrder,
  required String createdAt,
  required String updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$LedgersTableUpdateCompanionBuilder = LedgersCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<String> icon,
  Value<String> color,
  Value<int> sortOrder,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$LedgersTableFilterComposer
    extends Composer<_$AppDatabase, $LedgersTable> {
  $$LedgersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LedgersTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgersTable> {
  $$LedgersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LedgersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgersTable> {
  $$LedgersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$LedgersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgersTable,
          Ledger,
          $$LedgersTableFilterComposer,
          $$LedgersTableOrderingComposer,
          $$LedgersTableAnnotationComposer,
          $$LedgersTableCreateCompanionBuilder,
          $$LedgersTableUpdateCompanionBuilder,
          (Ledger, BaseReferences<_$AppDatabase, $LedgersTable, Ledger>),
          Ledger,
          PrefetchHooks Function()
        > {
  $$LedgersTableTableManager(_$AppDatabase db, $LedgersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgersCompanion(
                id: id,
                userId: userId,
                name: name,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgersCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LedgersTable, Ledger>(table),
                  BaseReferences<_$AppDatabase, $LedgersTable, Ledger>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LedgersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgersTable,
      Ledger,
      $$LedgersTableFilterComposer,
      $$LedgersTableOrderingComposer,
      $$LedgersTableAnnotationComposer,
      $$LedgersTableCreateCompanionBuilder,
      $$LedgersTableUpdateCompanionBuilder,
      (Ledger, BaseReferences<_$AppDatabase, $LedgersTable, Ledger>),
      Ledger,
      PrefetchHooks Function()
    >;
typedef $$BillsTableCreateCompanionBuilder = BillsCompanion Function({
  required String id,
  required String ledgerId,
  required String categoryId,
  required String type,
  required int amountCents,
  required String billDate,
  Value<String?> note,
  Value<String> source,
  required String createdAt,
  required String updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$BillsTableUpdateCompanionBuilder = BillsCompanion Function({
  Value<String> id,
  Value<String> ledgerId,
  Value<String> categoryId,
  Value<String> type,
  Value<int> amountCents,
  Value<String> billDate,
  Value<String?> note,
  Value<String> source,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$BillsTableFilterComposer extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billDate => $composableBuilder(
    column: $table.billDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BillsTableOrderingComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billDate => $composableBuilder(
    column: $table.billDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ledgerId =>
      $composableBuilder(column: $table.ledgerId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get billDate =>
      $composableBuilder(column: $table.billDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$BillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillsTable,
          Bill,
          $$BillsTableFilterComposer,
          $$BillsTableOrderingComposer,
          $$BillsTableAnnotationComposer,
          $$BillsTableCreateCompanionBuilder,
          $$BillsTableUpdateCompanionBuilder,
          (Bill, BaseReferences<_$AppDatabase, $BillsTable, Bill>),
          Bill,
          PrefetchHooks Function()
        > {
  $$BillsTableTableManager(_$AppDatabase db, $BillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ledgerId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String> billDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion(
                id: id,
                ledgerId: ledgerId,
                categoryId: categoryId,
                type: type,
                amountCents: amountCents,
                billDate: billDate,
                note: note,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ledgerId,
                required String categoryId,
                required String type,
                required int amountCents,
                required String billDate,
                Value<String?> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion.insert(
                id: id,
                ledgerId: ledgerId,
                categoryId: categoryId,
                type: type,
                amountCents: amountCents,
                billDate: billDate,
                note: note,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BillsTable, Bill>(table),
                  BaseReferences<_$AppDatabase, $BillsTable, Bill>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillsTable,
      Bill,
      $$BillsTableFilterComposer,
      $$BillsTableOrderingComposer,
      $$BillsTableAnnotationComposer,
      $$BillsTableCreateCompanionBuilder,
      $$BillsTableUpdateCompanionBuilder,
      (Bill, BaseReferences<_$AppDatabase, $BillsTable, Bill>),
      Bill,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String userId,
  required String name,
  required String type,
  Value<String> icon,
  Value<String> color,
  Value<bool> isCustom,
  Value<int> sortOrder,
  Value<String> updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<String> type,
  Value<String> icon,
  Value<String> color,
  Value<bool> isCustom,
  Value<int> sortOrder,
  Value<String> updatedAt,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                userId: userId,
                name: name,
                type: type,
                icon: icon,
                color: color,
                isCustom: isCustom,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                required String type,
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                type: type,
                icon: icon,
                color: color,
                isCustom: isCustom,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Category>(table),
                  BaseReferences<_$AppDatabase, $CategoriesTable, Category>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$LegacyDepositArchiveTableCreateCompanionBuilder =
    LegacyDepositArchiveCompanion Function({
      required String id,
      Value<String> userId,
      required String goalId,
      required int amountCents,
      Value<String?> sourceBillId,
      Value<String?> note,
      required String archivedAt,
      Value<int> rowid,
    });
typedef $$LegacyDepositArchiveTableUpdateCompanionBuilder =
    LegacyDepositArchiveCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> goalId,
      Value<int> amountCents,
      Value<String?> sourceBillId,
      Value<String?> note,
      Value<String> archivedAt,
      Value<int> rowid,
    });

class $$LegacyDepositArchiveTableFilterComposer
    extends Composer<_$AppDatabase, $LegacyDepositArchiveTable> {
  $$LegacyDepositArchiveTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceBillId => $composableBuilder(
    column: $table.sourceBillId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LegacyDepositArchiveTableOrderingComposer
    extends Composer<_$AppDatabase, $LegacyDepositArchiveTable> {
  $$LegacyDepositArchiveTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceBillId => $composableBuilder(
    column: $table.sourceBillId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LegacyDepositArchiveTableAnnotationComposer
    extends Composer<_$AppDatabase, $LegacyDepositArchiveTable> {
  $$LegacyDepositArchiveTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceBillId => $composableBuilder(
    column: $table.sourceBillId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );
}

class $$LegacyDepositArchiveTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LegacyDepositArchiveTable,
          LegacyDepositArchiveData,
          $$LegacyDepositArchiveTableFilterComposer,
          $$LegacyDepositArchiveTableOrderingComposer,
          $$LegacyDepositArchiveTableAnnotationComposer,
          $$LegacyDepositArchiveTableCreateCompanionBuilder,
          $$LegacyDepositArchiveTableUpdateCompanionBuilder,
          (
            LegacyDepositArchiveData,
            BaseReferences<
              _$AppDatabase,
              $LegacyDepositArchiveTable,
              LegacyDepositArchiveData
            >,
          ),
          LegacyDepositArchiveData,
          PrefetchHooks Function()
        > {
  $$LegacyDepositArchiveTableTableManager(
    _$AppDatabase db,
    $LegacyDepositArchiveTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LegacyDepositArchiveTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LegacyDepositArchiveTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LegacyDepositArchiveTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> goalId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String?> sourceBillId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LegacyDepositArchiveCompanion(
                id: id,
                userId: userId,
                goalId: goalId,
                amountCents: amountCents,
                sourceBillId: sourceBillId,
                note: note,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required String goalId,
                required int amountCents,
                Value<String?> sourceBillId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required String archivedAt,
                Value<int> rowid = const Value.absent(),
              }) => LegacyDepositArchiveCompanion.insert(
                id: id,
                userId: userId,
                goalId: goalId,
                amountCents: amountCents,
                sourceBillId: sourceBillId,
                note: note,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LegacyDepositArchiveTable,
                    LegacyDepositArchiveData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LegacyDepositArchiveTable,
                    LegacyDepositArchiveData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LegacyDepositArchiveTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LegacyDepositArchiveTable,
      LegacyDepositArchiveData,
      $$LegacyDepositArchiveTableFilterComposer,
      $$LegacyDepositArchiveTableOrderingComposer,
      $$LegacyDepositArchiveTableAnnotationComposer,
      $$LegacyDepositArchiveTableCreateCompanionBuilder,
      $$LegacyDepositArchiveTableUpdateCompanionBuilder,
      (
        LegacyDepositArchiveData,
        BaseReferences<
          _$AppDatabase,
          $LegacyDepositArchiveTable,
          LegacyDepositArchiveData
        >,
      ),
      LegacyDepositArchiveData,
      PrefetchHooks Function()
    >;
typedef $$AiAnalysisReportsTableCreateCompanionBuilder =
    AiAnalysisReportsCompanion Function({
      required String id,
      required String scopePeriodType,
      required String scopePeriodLabel,
      required String scopeLedgerKey,
      required String scopeAnchorDate,
      required String reportJson,
      required String dataVersion,
      required String createdAt,
      Value<String> updatedAt,
      required String expiresAt,
      Value<bool> isStale,
      Value<String?> goalKey,
      required String modelId,
      required String consentVersion,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$AiAnalysisReportsTableUpdateCompanionBuilder =
    AiAnalysisReportsCompanion Function({
      Value<String> id,
      Value<String> scopePeriodType,
      Value<String> scopePeriodLabel,
      Value<String> scopeLedgerKey,
      Value<String> scopeAnchorDate,
      Value<String> reportJson,
      Value<String> dataVersion,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> expiresAt,
      Value<bool> isStale,
      Value<String?> goalKey,
      Value<String> modelId,
      Value<String> consentVersion,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$AiAnalysisReportsTableFilterComposer
    extends Composer<_$AppDatabase, $AiAnalysisReportsTable> {
  $$AiAnalysisReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopePeriodType => $composableBuilder(
    column: $table.scopePeriodType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopePeriodLabel => $composableBuilder(
    column: $table.scopePeriodLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeLedgerKey => $composableBuilder(
    column: $table.scopeLedgerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeAnchorDate => $composableBuilder(
    column: $table.scopeAnchorDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportJson => $composableBuilder(
    column: $table.reportJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStale => $composableBuilder(
    column: $table.isStale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalKey => $composableBuilder(
    column: $table.goalKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consentVersion => $composableBuilder(
    column: $table.consentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiAnalysisReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiAnalysisReportsTable> {
  $$AiAnalysisReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopePeriodType => $composableBuilder(
    column: $table.scopePeriodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopePeriodLabel => $composableBuilder(
    column: $table.scopePeriodLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeLedgerKey => $composableBuilder(
    column: $table.scopeLedgerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeAnchorDate => $composableBuilder(
    column: $table.scopeAnchorDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportJson => $composableBuilder(
    column: $table.reportJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStale => $composableBuilder(
    column: $table.isStale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalKey => $composableBuilder(
    column: $table.goalKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consentVersion => $composableBuilder(
    column: $table.consentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiAnalysisReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiAnalysisReportsTable> {
  $$AiAnalysisReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scopePeriodType => $composableBuilder(
    column: $table.scopePeriodType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scopePeriodLabel => $composableBuilder(
    column: $table.scopePeriodLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scopeLedgerKey => $composableBuilder(
    column: $table.scopeLedgerKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scopeAnchorDate => $composableBuilder(
    column: $table.scopeAnchorDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reportJson => $composableBuilder(
    column: $table.reportJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataVersion => $composableBuilder(
    column: $table.dataVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<bool> get isStale =>
      $composableBuilder(column: $table.isStale, builder: (column) => column);

  GeneratedColumn<String> get goalKey =>
      $composableBuilder(column: $table.goalKey, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get consentVersion => $composableBuilder(
    column: $table.consentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$AiAnalysisReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiAnalysisReportsTable,
          AiAnalysisReport,
          $$AiAnalysisReportsTableFilterComposer,
          $$AiAnalysisReportsTableOrderingComposer,
          $$AiAnalysisReportsTableAnnotationComposer,
          $$AiAnalysisReportsTableCreateCompanionBuilder,
          $$AiAnalysisReportsTableUpdateCompanionBuilder,
          (
            AiAnalysisReport,
            BaseReferences<
              _$AppDatabase,
              $AiAnalysisReportsTable,
              AiAnalysisReport
            >,
          ),
          AiAnalysisReport,
          PrefetchHooks Function()
        > {
  $$AiAnalysisReportsTableTableManager(
    _$AppDatabase db,
    $AiAnalysisReportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiAnalysisReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiAnalysisReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiAnalysisReportsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scopePeriodType = const Value.absent(),
                Value<String> scopePeriodLabel = const Value.absent(),
                Value<String> scopeLedgerKey = const Value.absent(),
                Value<String> scopeAnchorDate = const Value.absent(),
                Value<String> reportJson = const Value.absent(),
                Value<String> dataVersion = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> expiresAt = const Value.absent(),
                Value<bool> isStale = const Value.absent(),
                Value<String?> goalKey = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> consentVersion = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiAnalysisReportsCompanion(
                id: id,
                scopePeriodType: scopePeriodType,
                scopePeriodLabel: scopePeriodLabel,
                scopeLedgerKey: scopeLedgerKey,
                scopeAnchorDate: scopeAnchorDate,
                reportJson: reportJson,
                dataVersion: dataVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                expiresAt: expiresAt,
                isStale: isStale,
                goalKey: goalKey,
                modelId: modelId,
                consentVersion: consentVersion,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scopePeriodType,
                required String scopePeriodLabel,
                required String scopeLedgerKey,
                required String scopeAnchorDate,
                required String reportJson,
                required String dataVersion,
                required String createdAt,
                Value<String> updatedAt = const Value.absent(),
                required String expiresAt,
                Value<bool> isStale = const Value.absent(),
                Value<String?> goalKey = const Value.absent(),
                required String modelId,
                required String consentVersion,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiAnalysisReportsCompanion.insert(
                id: id,
                scopePeriodType: scopePeriodType,
                scopePeriodLabel: scopePeriodLabel,
                scopeLedgerKey: scopeLedgerKey,
                scopeAnchorDate: scopeAnchorDate,
                reportJson: reportJson,
                dataVersion: dataVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                expiresAt: expiresAt,
                isStale: isStale,
                goalKey: goalKey,
                modelId: modelId,
                consentVersion: consentVersion,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiAnalysisReportsTable, AiAnalysisReport>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AiAnalysisReportsTable,
                    AiAnalysisReport
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiAnalysisReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiAnalysisReportsTable,
      AiAnalysisReport,
      $$AiAnalysisReportsTableFilterComposer,
      $$AiAnalysisReportsTableOrderingComposer,
      $$AiAnalysisReportsTableAnnotationComposer,
      $$AiAnalysisReportsTableCreateCompanionBuilder,
      $$AiAnalysisReportsTableUpdateCompanionBuilder,
      (
        AiAnalysisReport,
        BaseReferences<
          _$AppDatabase,
          $AiAnalysisReportsTable,
          AiAnalysisReport
        >,
      ),
      AiAnalysisReport,
      PrefetchHooks Function()
    >;
typedef $$SyncStatesTableCreateCompanionBuilder = SyncStatesCompanion Function({
  required String id,
  Value<int> lastPullSyncedAt,
  Value<String> lastPushAt,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$SyncStatesTableUpdateCompanionBuilder = SyncStatesCompanion Function({
  Value<String> id,
  Value<int> lastPullSyncedAt,
  Value<String> lastPushAt,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$SyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPullSyncedAt => $composableBuilder(
    column: $table.lastPullSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPullSyncedAt => $composableBuilder(
    column: $table.lastPullSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lastPullSyncedAt => $composableBuilder(
    column: $table.lastPullSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStatesTable,
          SyncState,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (
            SyncState,
            BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>,
          ),
          SyncState,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(_$AppDatabase db, $SyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> lastPullSyncedAt = const Value.absent(),
                Value<String> lastPushAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion(
                id: id,
                lastPullSyncedAt: lastPullSyncedAt,
                lastPushAt: lastPushAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> lastPullSyncedAt = const Value.absent(),
                Value<String> lastPushAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion.insert(
                id: id,
                lastPullSyncedAt: lastPullSyncedAt,
                lastPushAt: lastPushAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStatesTable, SyncState>(table),
                  BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStatesTable,
      SyncState,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (SyncState, BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>),
      SyncState,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$SavingsGoalsTableTableManager get savingsGoals =>
      $$SavingsGoalsTableTableManager(_db, _db.savingsGoals);
  $$GoalLedgerBindingsTableTableManager get goalLedgerBindings =>
      $$GoalLedgerBindingsTableTableManager(_db, _db.goalLedgerBindings);
  $$GoalMilestonesTableTableManager get goalMilestones =>
      $$GoalMilestonesTableTableManager(_db, _db.goalMilestones);
  $$LedgersTableTableManager get ledgers =>
      $$LedgersTableTableManager(_db, _db.ledgers);
  $$BillsTableTableManager get bills =>
      $$BillsTableTableManager(_db, _db.bills);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$LegacyDepositArchiveTableTableManager get legacyDepositArchive =>
      $$LegacyDepositArchiveTableTableManager(_db, _db.legacyDepositArchive);
  $$AiAnalysisReportsTableTableManager get aiAnalysisReports =>
      $$AiAnalysisReportsTableTableManager(_db, _db.aiAnalysisReports);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
}
