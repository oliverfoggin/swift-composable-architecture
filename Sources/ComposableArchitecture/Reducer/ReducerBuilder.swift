/// A result builder for combining reducers into a single reducer by running each, one after the
/// other, and returning their merged effects.
///
/// It is most common to encounter a reducer builder context when conforming a type to
/// ``Reducer`` and implementing its ``Reducer/body-swift.property-97ymy`` property.
///
/// See ``CombineReducers`` for an entry point into a reducer builder context.
@resultBuilder
public enum ReducerBuilder<State, Action> {
  #if swift(>=5.7)
    @inlinable
    public static func buildArray(
      _ reducers: [some Reducer<State, Action>]
    ) -> some Reducer<State, Action> {
      _SequenceMany(reducers: reducers)
    }

    @inlinable
    public static func buildBlock() -> some Reducer<State, Action> {
      EmptyReducer()
    }

    @inlinable
    public static func buildBlock(
      _ reducer: some Reducer<State, Action>
    ) -> some Reducer<State, Action> {
      reducer
    }

    @inlinable
    public static func buildEither<R0: Reducer, R1: Reducer>(
      first reducer: R0
    ) -> _Conditional<R0, R1>
    where R0.State == State, R0.Action == Action, R1.State == State, R1.Action == Action {
      .first(reducer)
    }

    @inlinable
    public static func buildEither<R0: Reducer, R1: Reducer>(
      second reducer: R1
    ) -> _Conditional<R0, R1>
    where R0.State == State, R0.Action == Action, R1.State == State, R1.Action == Action {
      .second(reducer)
    }

    @inlinable
    public static func buildExpression(
      _ expression: some Reducer<State, Action>
    ) -> some Reducer<State, Action> {
      expression
    }

    @inlinable
    public static func buildFinalResult(
      _ reducer: some Reducer<State, Action>
    ) -> some Reducer<State, Action> {
      reducer
    }

    @inlinable
    public static func buildLimitedAvailability(
      _ wrapped: some Reducer<State, Action>
    ) -> Reduce<State, Action> {
      Reduce(wrapped)
    }

    @inlinable
    public static func buildOptional(
      _ wrapped: (some Reducer<State, Action>)?
    ) -> some Reducer<State, Action> {
      wrapped
    }

    @inlinable
    public static func buildPartialBlock(
      first: some Reducer<State, Action>
    ) -> some Reducer<State, Action> {
      first
    }

    @inlinable
    public static func buildPartialBlock(
      accumulated: some Reducer<State, Action>, next: some Reducer<State, Action>
    ) -> some Reducer<State, Action> {
      _Sequence(accumulated, next)
    }
  #else
    @inlinable
    public static func buildArray<R: Reducer>(_ reducers: [R]) -> _SequenceMany<R>
    where R.State == State, R.Action == Action {
      _SequenceMany(reducers: reducers)
    }

    @inlinable
    public static func buildBlock() -> EmptyReducer<State, Action> {
      EmptyReducer()
    }

    @inlinable
    public static func buildBlock<R: Reducer>(_ reducer: R) -> R
    where R.State == State, R.Action == Action {
      reducer
    }

    @inlinable
    public static func buildBlock<
      R0: Reducer,
      R1: Reducer
    >(
      _ r0: R0,
      _ r1: R1
    ) -> _Sequence<R0, R1>
    where R0.State == State, R0.Action == Action {
      _Sequence(r0, r1)
    }

    @inlinable
    public static func buildBlock<
      R0: Reducer,
      R1: Reducer,
      R2: Reducer
    >(
      _ r0: R0,
      _ r1: R1,
      _ r2: R2
    ) -> _Sequence<_Sequence<R0, R1>, R2>
    where R0.State == State, R0.Action == Action {
      _Sequence(_Sequence(r0, r1), r2)
    }

    @inlinable
    public static func buildBlock<
      R0: Reducer,
      R1: Reducer,
      R2: Reducer,
      R3: Reducer
    >(
      _ r0: R0,
      _ r1: R1,
      _ r2: R2,
      _ r3: R3
    ) -> _Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>
    where R0.State == State, R0.Action == Action {
      _Sequence(_Sequence(_Sequence(r0, r1), r2), r3)
    }

    @inlinable
    public static func buildBlock<
      R0: Reducer,
      R1: Reducer,
      R2: Reducer,
      R3: Reducer,
      R4: Reducer
    >(
      _ r0: R0,
      _ r1: R1,
      _ r2: R2,
      _ r3: R3,
      _ r4: R4
    ) -> _Sequence<_Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>, R4>
    where R0.State == State, R0.Action == Action {
      _Sequence(_Sequence(_Sequence(_Sequence(r0, r1), r2), r3), r4)
    }

    @inlinable
    public static func buildBlock<
      R0: Reducer,
      R1: Reducer,
      R2: Reducer,
      R3: Reducer,
      R4: Reducer,
      R5: Reducer
    >(
      _ r0: R0,
      _ r1: R1,
      _ r2: R2,
      _ r3: R3,
      _ r4: R4,
      _ r5: R5
    ) -> _Sequence<_Sequence<_Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>, R4>, R5>
    where R0.State == State, R0.Action == Action {
      _Sequence(_Sequence(_Sequence(_Sequence(_Sequence(r0, r1), r2), r3), r4), r5)
    }

    @inlinable
    public static func buildBlock<
      R0: Reducer,
      R1: Reducer,
      R2: Reducer,
      R3: Reducer,
      R4: Reducer,
      R5: Reducer,
      R6: Reducer
    >(
      _ r0: R0,
      _ r1: R1,
      _ r2: R2,
      _ r3: R3,
      _ r4: R4,
      _ r5: R5,
      _ r6: R6
    ) -> _Sequence<
      _Sequence<_Sequence<_Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>, R4>, R5>, R6
    >
    where R0.State == State, R0.Action == Action {
      _Sequence(_Sequence(_Sequence(_Sequence(_Sequence(_Sequence(r0, r1), r2), r3), r4), r5), r6)
    }

    @inlinable
    public static func buildBlock<
      R0: Reducer,
      R1: Reducer,
      R2: Reducer,
      R3: Reducer,
      R4: Reducer,
      R5: Reducer,
      R6: Reducer,
      R7: Reducer
    >(
      _ r0: R0,
      _ r1: R1,
      _ r2: R2,
      _ r3: R3,
      _ r4: R4,
      _ r5: R5,
      _ r6: R6,
      _ r7: R7
    ) -> _Sequence<
      _Sequence<_Sequence<_Sequence<_Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>, R4>, R5>, R6>,
      R7
    >
    where R0.State == State, R0.Action == Action {
      _Sequence(
        _Sequence(
          _Sequence(_Sequence(_Sequence(_Sequence(_Sequence(r0, r1), r2), r3), r4), r5), r6
        ),
        r7
      )
    }

    @inlinable
    public static func buildBlock<
      R0: Reducer,
      R1: Reducer,
      R2: Reducer,
      R3: Reducer,
      R4: Reducer,
      R5: Reducer,
      R6: Reducer,
      R7: Reducer,
      R8: Reducer
    >(
      _ r0: R0,
      _ r1: R1,
      _ r2: R2,
      _ r3: R3,
      _ r4: R4,
      _ r5: R5,
      _ r6: R6,
      _ r7: R7,
      _ r8: R8
    ) -> _Sequence<
      _Sequence<
        _Sequence<
          _Sequence<_Sequence<_Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>, R4>, R5>, R6
        >,
        R7
      >,
      R8
    >
    where R0.State == State, R0.Action == Action {
      _Sequence(
        _Sequence(
          _Sequence(
            _Sequence(_Sequence(_Sequence(_Sequence(_Sequence(r0, r1), r2), r3), r4), r5), r6
          ),
          r7
        ),
        r8
      )
    }

    @inlinable
    public static func buildBlock<
      R0: Reducer,
      R1: Reducer,
      R2: Reducer,
      R3: Reducer,
      R4: Reducer,
      R5: Reducer,
      R6: Reducer,
      R7: Reducer,
      R8: Reducer,
      R9: Reducer
    >(
      _ r0: R0,
      _ r1: R1,
      _ r2: R2,
      _ r3: R3,
      _ r4: R4,
      _ r5: R5,
      _ r6: R6,
      _ r7: R7,
      _ r8: R8,
      _ r9: R9
    ) -> _Sequence<
      _Sequence<
        _Sequence<
          _Sequence<
            _Sequence<_Sequence<_Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>, R4>, R5>, R6
          >,
          R7
        >,
        R8
      >,
      R9
    >
    where R0.State == State, R0.Action == Action {
      _Sequence(
        _Sequence(
          _Sequence(
            _Sequence(
              _Sequence(_Sequence(_Sequence(_Sequence(_Sequence(r0, r1), r2), r3), r4), r5), r6
            ),
            r7
          ),
          r8
        ),
        r9
      )
    }

    @inlinable
    public static func buildEither<R0: Reducer, R1: Reducer>(
      first reducer: R0
    ) -> _Conditional<R0, R1>
    where R0.State == State, R0.Action == Action {
      .first(reducer)
    }

    @inlinable
    public static func buildEither<R0: Reducer, R1: Reducer>(
      second reducer: R1
    ) -> _Conditional<R0, R1>
    where R1.State == State, R1.Action == Action {
      .second(reducer)
    }

    @inlinable
    public static func buildExpression<R: Reducer>(_ expression: R) -> R
    where R.State == State, R.Action == Action {
      expression
    }

    @inlinable
    public static func buildFinalResult<R: Reducer>(_ reducer: R) -> R
    where R.State == State, R.Action == Action {
      reducer
    }

    @_disfavoredOverload
    @inlinable
    public static func buildFinalResult<R: Reducer>(_ reducer: R) -> Reduce<State, Action>
    where R.State == State, R.Action == Action {
      Reduce(reducer)
    }

    @inlinable
    public static func buildLimitedAvailability<R: Reducer>(
      _ wrapped: R
    ) -> Reduce<R.State, R.Action>
    where R.State == State, R.Action == Action {
      Reduce(wrapped)
    }

    @inlinable
    public static func buildOptional<R: Reducer>(_ wrapped: R?) -> R?
    where R.State == State, R.Action == Action {
      wrapped
    }
  #endif

  public enum _Conditional<First: Reducer, Second: Reducer>: Reducer
  where
    First.State == Second.State,
    First.Action == Second.Action
  {
    case first(First)
    case second(Second)

    @inlinable
    public func reduce(into state: inout First.State, action: First.Action) -> Effect<
      First.Action
    > {
      switch self {
      case let .first(first):
        return first.reduce(into: &state, action: action)

      case let .second(second):
        return second.reduce(into: &state, action: action)
      }
    }
  }

  public struct _Sequence<R0: Reducer, R1: Reducer>: Reducer
  where R0.State == R1.State, R0.Action == R1.Action {
    @usableFromInline
    let r0: R0

    @usableFromInline
    let r1: R1

    @usableFromInline
    init(_ r0: R0, _ r1: R1) {
      self.r0 = r0
      self.r1 = r1
    }

    @inlinable
    public func reduce(into state: inout R0.State, action: R0.Action) -> Effect<R0.Action> {
      self.r0.reduce(into: &state, action: action)
        .merge(with: self.r1.reduce(into: &state, action: action))
    }
  }

  public struct _SequenceMany<Element: Reducer>: Reducer {
    @usableFromInline
    let reducers: [Element]

    @usableFromInline
    init(reducers: [Element]) {
      self.reducers = reducers
    }

    @inlinable
    public func reduce(
      into state: inout Element.State, action: Element.Action
    ) -> Effect<Element.Action> {
      self.reducers.reduce(.none) { $0.merge(with: $1.reduce(into: &state, action: action)) }
    }
  }
}

public typealias ReducerBuilderOf<R: Reducer> = ReducerBuilder<R.State, R.Action>
