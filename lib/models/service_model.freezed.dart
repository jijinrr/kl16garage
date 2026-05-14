// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) {
  return _ServiceModel.fromJson(json);
}

/// @nodoc
mixin _$ServiceModel {
  String get id => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get vehicleNumber => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get vehicleType => throw _privateConstructorUsedError;
  List<String> get services => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  double get advanceAmount => throw _privateConstructorUsedError;
  double get balanceAmount => throw _privateConstructorUsedError;
  String get paymentStatus =>
      throw _privateConstructorUsedError; // 'Completed' | 'Partial' | 'Pending'
  String get paymentMethod =>
      throw _privateConstructorUsedError; // 'Cash' | 'UPI' | 'Both'
  String get status =>
      throw _privateConstructorUsedError; // 'Pending' | 'Completed'
  String get staffId => throw _privateConstructorUsedError;
  String get staffName => throw _privateConstructorUsedError;
  List<String> get beforePhotos => throw _privateConstructorUsedError;
  List<String> get afterPhotos => throw _privateConstructorUsedError;
  String get comments => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this ServiceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceModelCopyWith<ServiceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceModelCopyWith<$Res> {
  factory $ServiceModelCopyWith(
    ServiceModel value,
    $Res Function(ServiceModel) then,
  ) = _$ServiceModelCopyWithImpl<$Res, ServiceModel>;
  @useResult
  $Res call({
    String id,
    String customerName,
    String vehicleNumber,
    String phone,
    String vehicleType,
    List<String> services,
    double totalAmount,
    double advanceAmount,
    double balanceAmount,
    String paymentStatus,
    String paymentMethod,
    String status,
    String staffId,
    String staffName,
    List<String> beforePhotos,
    List<String> afterPhotos,
    String comments,
    DateTime? createdAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$ServiceModelCopyWithImpl<$Res, $Val extends ServiceModel>
    implements $ServiceModelCopyWith<$Res> {
  _$ServiceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? vehicleNumber = null,
    Object? phone = null,
    Object? vehicleType = null,
    Object? services = null,
    Object? totalAmount = null,
    Object? advanceAmount = null,
    Object? balanceAmount = null,
    Object? paymentStatus = null,
    Object? paymentMethod = null,
    Object? status = null,
    Object? staffId = null,
    Object? staffName = null,
    Object? beforePhotos = null,
    Object? afterPhotos = null,
    Object? comments = null,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicleNumber: null == vehicleNumber
                ? _value.vehicleNumber
                : vehicleNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicleType: null == vehicleType
                ? _value.vehicleType
                : vehicleType // ignore: cast_nullable_to_non_nullable
                      as String,
            services: null == services
                ? _value.services
                : services // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            advanceAmount: null == advanceAmount
                ? _value.advanceAmount
                : advanceAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            balanceAmount: null == balanceAmount
                ? _value.balanceAmount
                : balanceAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            paymentStatus: null == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentMethod: null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            staffId: null == staffId
                ? _value.staffId
                : staffId // ignore: cast_nullable_to_non_nullable
                      as String,
            staffName: null == staffName
                ? _value.staffName
                : staffName // ignore: cast_nullable_to_non_nullable
                      as String,
            beforePhotos: null == beforePhotos
                ? _value.beforePhotos
                : beforePhotos // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            afterPhotos: null == afterPhotos
                ? _value.afterPhotos
                : afterPhotos // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            comments: null == comments
                ? _value.comments
                : comments // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServiceModelImplCopyWith<$Res>
    implements $ServiceModelCopyWith<$Res> {
  factory _$$ServiceModelImplCopyWith(
    _$ServiceModelImpl value,
    $Res Function(_$ServiceModelImpl) then,
  ) = __$$ServiceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String customerName,
    String vehicleNumber,
    String phone,
    String vehicleType,
    List<String> services,
    double totalAmount,
    double advanceAmount,
    double balanceAmount,
    String paymentStatus,
    String paymentMethod,
    String status,
    String staffId,
    String staffName,
    List<String> beforePhotos,
    List<String> afterPhotos,
    String comments,
    DateTime? createdAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$ServiceModelImplCopyWithImpl<$Res>
    extends _$ServiceModelCopyWithImpl<$Res, _$ServiceModelImpl>
    implements _$$ServiceModelImplCopyWith<$Res> {
  __$$ServiceModelImplCopyWithImpl(
    _$ServiceModelImpl _value,
    $Res Function(_$ServiceModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? vehicleNumber = null,
    Object? phone = null,
    Object? vehicleType = null,
    Object? services = null,
    Object? totalAmount = null,
    Object? advanceAmount = null,
    Object? balanceAmount = null,
    Object? paymentStatus = null,
    Object? paymentMethod = null,
    Object? status = null,
    Object? staffId = null,
    Object? staffName = null,
    Object? beforePhotos = null,
    Object? afterPhotos = null,
    Object? comments = null,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$ServiceModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleNumber: null == vehicleNumber
            ? _value.vehicleNumber
            : vehicleNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleType: null == vehicleType
            ? _value.vehicleType
            : vehicleType // ignore: cast_nullable_to_non_nullable
                  as String,
        services: null == services
            ? _value._services
            : services // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        advanceAmount: null == advanceAmount
            ? _value.advanceAmount
            : advanceAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        balanceAmount: null == balanceAmount
            ? _value.balanceAmount
            : balanceAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        paymentStatus: null == paymentStatus
            ? _value.paymentStatus
            : paymentStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentMethod: null == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        staffId: null == staffId
            ? _value.staffId
            : staffId // ignore: cast_nullable_to_non_nullable
                  as String,
        staffName: null == staffName
            ? _value.staffName
            : staffName // ignore: cast_nullable_to_non_nullable
                  as String,
        beforePhotos: null == beforePhotos
            ? _value._beforePhotos
            : beforePhotos // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        afterPhotos: null == afterPhotos
            ? _value._afterPhotos
            : afterPhotos // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        comments: null == comments
            ? _value.comments
            : comments // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceModelImpl implements _ServiceModel {
  const _$ServiceModelImpl({
    required this.id,
    required this.customerName,
    required this.vehicleNumber,
    this.phone = '',
    this.vehicleType = 'Sedan',
    final List<String> services = const [],
    this.totalAmount = 0.0,
    this.advanceAmount = 0.0,
    this.balanceAmount = 0.0,
    this.paymentStatus = 'Pending',
    this.paymentMethod = 'Cash',
    this.status = 'Pending',
    this.staffId = '',
    this.staffName = '',
    final List<String> beforePhotos = const [],
    final List<String> afterPhotos = const [],
    this.comments = '',
    this.createdAt,
    this.completedAt,
  }) : _services = services,
       _beforePhotos = beforePhotos,
       _afterPhotos = afterPhotos;

  factory _$ServiceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceModelImplFromJson(json);

  @override
  final String id;
  @override
  final String customerName;
  @override
  final String vehicleNumber;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String vehicleType;
  final List<String> _services;
  @override
  @JsonKey()
  List<String> get services {
    if (_services is EqualUnmodifiableListView) return _services;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_services);
  }

  @override
  @JsonKey()
  final double totalAmount;
  @override
  @JsonKey()
  final double advanceAmount;
  @override
  @JsonKey()
  final double balanceAmount;
  @override
  @JsonKey()
  final String paymentStatus;
  // 'Completed' | 'Partial' | 'Pending'
  @override
  @JsonKey()
  final String paymentMethod;
  // 'Cash' | 'UPI' | 'Both'
  @override
  @JsonKey()
  final String status;
  // 'Pending' | 'Completed'
  @override
  @JsonKey()
  final String staffId;
  @override
  @JsonKey()
  final String staffName;
  final List<String> _beforePhotos;
  @override
  @JsonKey()
  List<String> get beforePhotos {
    if (_beforePhotos is EqualUnmodifiableListView) return _beforePhotos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_beforePhotos);
  }

  final List<String> _afterPhotos;
  @override
  @JsonKey()
  List<String> get afterPhotos {
    if (_afterPhotos is EqualUnmodifiableListView) return _afterPhotos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_afterPhotos);
  }

  @override
  @JsonKey()
  final String comments;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'ServiceModel(id: $id, customerName: $customerName, vehicleNumber: $vehicleNumber, phone: $phone, vehicleType: $vehicleType, services: $services, totalAmount: $totalAmount, advanceAmount: $advanceAmount, balanceAmount: $balanceAmount, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, status: $status, staffId: $staffId, staffName: $staffName, beforePhotos: $beforePhotos, afterPhotos: $afterPhotos, comments: $comments, createdAt: $createdAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.vehicleNumber, vehicleNumber) ||
                other.vehicleNumber == vehicleNumber) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            const DeepCollectionEquality().equals(other._services, _services) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.advanceAmount, advanceAmount) ||
                other.advanceAmount == advanceAmount) &&
            (identical(other.balanceAmount, balanceAmount) ||
                other.balanceAmount == balanceAmount) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.staffId, staffId) || other.staffId == staffId) &&
            (identical(other.staffName, staffName) ||
                other.staffName == staffName) &&
            const DeepCollectionEquality().equals(
              other._beforePhotos,
              _beforePhotos,
            ) &&
            const DeepCollectionEquality().equals(
              other._afterPhotos,
              _afterPhotos,
            ) &&
            (identical(other.comments, comments) ||
                other.comments == comments) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    customerName,
    vehicleNumber,
    phone,
    vehicleType,
    const DeepCollectionEquality().hash(_services),
    totalAmount,
    advanceAmount,
    balanceAmount,
    paymentStatus,
    paymentMethod,
    status,
    staffId,
    staffName,
    const DeepCollectionEquality().hash(_beforePhotos),
    const DeepCollectionEquality().hash(_afterPhotos),
    comments,
    createdAt,
    completedAt,
  ]);

  /// Create a copy of ServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceModelImplCopyWith<_$ServiceModelImpl> get copyWith =>
      __$$ServiceModelImplCopyWithImpl<_$ServiceModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceModelImplToJson(this);
  }
}

abstract class _ServiceModel implements ServiceModel {
  const factory _ServiceModel({
    required final String id,
    required final String customerName,
    required final String vehicleNumber,
    final String phone,
    final String vehicleType,
    final List<String> services,
    final double totalAmount,
    final double advanceAmount,
    final double balanceAmount,
    final String paymentStatus,
    final String paymentMethod,
    final String status,
    final String staffId,
    final String staffName,
    final List<String> beforePhotos,
    final List<String> afterPhotos,
    final String comments,
    final DateTime? createdAt,
    final DateTime? completedAt,
  }) = _$ServiceModelImpl;

  factory _ServiceModel.fromJson(Map<String, dynamic> json) =
      _$ServiceModelImpl.fromJson;

  @override
  String get id;
  @override
  String get customerName;
  @override
  String get vehicleNumber;
  @override
  String get phone;
  @override
  String get vehicleType;
  @override
  List<String> get services;
  @override
  double get totalAmount;
  @override
  double get advanceAmount;
  @override
  double get balanceAmount;
  @override
  String get paymentStatus; // 'Completed' | 'Partial' | 'Pending'
  @override
  String get paymentMethod; // 'Cash' | 'UPI' | 'Both'
  @override
  String get status; // 'Pending' | 'Completed'
  @override
  String get staffId;
  @override
  String get staffName;
  @override
  List<String> get beforePhotos;
  @override
  List<String> get afterPhotos;
  @override
  String get comments;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of ServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceModelImplCopyWith<_$ServiceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
