// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWordEntryCollection on Isar {
  IsarCollection<WordEntry> get wordEntrys => this.collection();
}

const WordEntrySchema = CollectionSchema(
  name: r'WordEntry',
  id: 5100680854566616813,
  properties: {
    r'bookPath': PropertySchema(
      id: 0,
      name: r'bookPath',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'pageNumber': PropertySchema(
      id: 2,
      name: r'pageNumber',
      type: IsarType.long,
    ),
    r'translation': PropertySchema(
      id: 3,
      name: r'translation',
      type: IsarType.string,
    ),
    r'wordNormalized': PropertySchema(
      id: 4,
      name: r'wordNormalized',
      type: IsarType.string,
    ),
    r'wordOriginal': PropertySchema(
      id: 5,
      name: r'wordOriginal',
      type: IsarType.string,
    ),
  },
  estimateSize: _wordEntryEstimateSize,
  serialize: _wordEntrySerialize,
  deserialize: _wordEntryDeserialize,
  deserializeProp: _wordEntryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _wordEntryGetId,
  getLinks: _wordEntryGetLinks,
  attach: _wordEntryAttach,
  version: '3.1.0+1',
);

int _wordEntryEstimateSize(
  WordEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bookPath.length * 3;
  {
    final value = object.translation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.wordNormalized.length * 3;
  bytesCount += 3 + object.wordOriginal.length * 3;
  return bytesCount;
}

void _wordEntrySerialize(
  WordEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bookPath);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.pageNumber);
  writer.writeString(offsets[3], object.translation);
  writer.writeString(offsets[4], object.wordNormalized);
  writer.writeString(offsets[5], object.wordOriginal);
}

WordEntry _wordEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WordEntry();
  object.bookPath = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.pageNumber = reader.readLong(offsets[2]);
  object.translation = reader.readStringOrNull(offsets[3]);
  object.wordNormalized = reader.readString(offsets[4]);
  object.wordOriginal = reader.readString(offsets[5]);
  return object;
}

P _wordEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _wordEntryGetId(WordEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _wordEntryGetLinks(WordEntry object) {
  return [];
}

void _wordEntryAttach(IsarCollection<dynamic> col, Id id, WordEntry object) {
  object.id = id;
}

extension WordEntryQueryWhereSort
    on QueryBuilder<WordEntry, WordEntry, QWhere> {
  QueryBuilder<WordEntry, WordEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WordEntryQueryWhere
    on QueryBuilder<WordEntry, WordEntry, QWhereClause> {
  QueryBuilder<WordEntry, WordEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension WordEntryQueryFilter
    on QueryBuilder<WordEntry, WordEntry, QFilterCondition> {
  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> bookPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bookPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> bookPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bookPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> bookPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bookPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> bookPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bookPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> bookPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'bookPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> bookPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'bookPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> bookPathContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'bookPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> bookPathMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'bookPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> bookPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bookPath', value: ''),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  bookPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'bookPath', value: ''),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> pageNumberEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pageNumber', value: value),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  pageNumberGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pageNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> pageNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pageNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> pageNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pageNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  translationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'translation'),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  translationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'translation'),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> translationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'translation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  translationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'translation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> translationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'translation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> translationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'translation',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  translationStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'translation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> translationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'translation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> translationContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'translation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> translationMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'translation',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  translationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'translation', value: ''),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  translationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'translation', value: ''),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordNormalizedEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'wordNormalized',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordNormalizedGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'wordNormalized',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordNormalizedLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'wordNormalized',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordNormalizedBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'wordNormalized',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordNormalizedStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'wordNormalized',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordNormalizedEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'wordNormalized',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordNormalizedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'wordNormalized',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordNormalizedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'wordNormalized',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordNormalizedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'wordNormalized', value: ''),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordNormalizedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'wordNormalized', value: ''),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> wordOriginalEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'wordOriginal',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordOriginalGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'wordOriginal',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordOriginalLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'wordOriginal',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> wordOriginalBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'wordOriginal',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordOriginalStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'wordOriginal',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordOriginalEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'wordOriginal',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordOriginalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'wordOriginal',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition> wordOriginalMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'wordOriginal',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordOriginalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'wordOriginal', value: ''),
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterFilterCondition>
  wordOriginalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'wordOriginal', value: ''),
      );
    });
  }
}

extension WordEntryQueryObject
    on QueryBuilder<WordEntry, WordEntry, QFilterCondition> {}

extension WordEntryQueryLinks
    on QueryBuilder<WordEntry, WordEntry, QFilterCondition> {}

extension WordEntryQuerySortBy on QueryBuilder<WordEntry, WordEntry, QSortBy> {
  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> sortByBookPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookPath', Sort.asc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> sortByBookPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookPath', Sort.desc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> sortByPageNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.asc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> sortByPageNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.desc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> sortByTranslation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translation', Sort.asc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> sortByTranslationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translation', Sort.desc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> sortByWordNormalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordNormalized', Sort.asc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> sortByWordNormalizedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordNormalized', Sort.desc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> sortByWordOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordOriginal', Sort.asc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> sortByWordOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordOriginal', Sort.desc);
    });
  }
}

extension WordEntryQuerySortThenBy
    on QueryBuilder<WordEntry, WordEntry, QSortThenBy> {
  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenByBookPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookPath', Sort.asc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenByBookPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookPath', Sort.desc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenByPageNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.asc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenByPageNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.desc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenByTranslation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translation', Sort.asc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenByTranslationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translation', Sort.desc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenByWordNormalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordNormalized', Sort.asc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenByWordNormalizedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordNormalized', Sort.desc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenByWordOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordOriginal', Sort.asc);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QAfterSortBy> thenByWordOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordOriginal', Sort.desc);
    });
  }
}

extension WordEntryQueryWhereDistinct
    on QueryBuilder<WordEntry, WordEntry, QDistinct> {
  QueryBuilder<WordEntry, WordEntry, QDistinct> distinctByBookPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<WordEntry, WordEntry, QDistinct> distinctByPageNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageNumber');
    });
  }

  QueryBuilder<WordEntry, WordEntry, QDistinct> distinctByTranslation({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'translation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WordEntry, WordEntry, QDistinct> distinctByWordNormalized({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'wordNormalized',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WordEntry, WordEntry, QDistinct> distinctByWordOriginal({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wordOriginal', caseSensitive: caseSensitive);
    });
  }
}

extension WordEntryQueryProperty
    on QueryBuilder<WordEntry, WordEntry, QQueryProperty> {
  QueryBuilder<WordEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WordEntry, String, QQueryOperations> bookPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookPath');
    });
  }

  QueryBuilder<WordEntry, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<WordEntry, int, QQueryOperations> pageNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageNumber');
    });
  }

  QueryBuilder<WordEntry, String?, QQueryOperations> translationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'translation');
    });
  }

  QueryBuilder<WordEntry, String, QQueryOperations> wordNormalizedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wordNormalized');
    });
  }

  QueryBuilder<WordEntry, String, QQueryOperations> wordOriginalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wordOriginal');
    });
  }
}
