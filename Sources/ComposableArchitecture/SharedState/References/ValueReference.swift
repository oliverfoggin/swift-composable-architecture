import Dependencies
import Foundation

#if canImport(Combine)
  import Combine
#endif
#if canImport(Perception)
  import Perception
#endif

extension Shared where Persistence: PersistenceKey<Value> {
  public init(
    wrappedValue value: Value,
    _ persistenceKey: Persistence,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) {
    self.init(
      reference: {
        @Dependency(PersistentReferencesKey.self) var references
        return references.withValue {
          if let (count, reference) = $0[persistenceKey] {
            $0[persistenceKey] = (count + 1, reference)
            return reference
          } else {
            let reference = ValueReference(
              initialValue: value,
              persistenceKey: persistenceKey,
              fileID: fileID,
              line: line
            )
            $0[persistenceKey] = (1, reference)
            return reference
          }
        }
      }(),
      keyPath: \Value.self,
      onCancel: {
          @Dependency(PersistentReferencesKey.self) var references
          return references.withValue {
              if let (count, reference) = $0[persistenceKey] {
                  if count == 1 {
                      $0[persistenceKey] = nil
                  } else {
                      $0[persistenceKey] = (count - 1, reference)
                  }
                  return
              }
          }
      }
    )
  }

  public init<Wrapped>(
    _ persistenceKey: Persistence,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) where Value == Wrapped? {
    self.init(wrappedValue: nil, persistenceKey, fileID: fileID, line: line)
  }

  @_disfavoredOverload
  public init(
    _ persistenceKey: Persistence,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) throws {
    guard let initialValue = persistenceKey.load(initialValue: nil)
    else {
      throw LoadError()
    }
    self.init(wrappedValue: initialValue, persistenceKey, fileID: fileID, line: line)
  }
}

extension SharedReader where Persistence: PersistenceReaderKey<Value> {
  public init(
    wrappedValue value: Value,
    _ persistenceKey: Persistence,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) {
    self.init(
      reference: {
        @Dependency(PersistentReferencesKey.self) var references
        return references.withValue {
          if let (count, reference) = $0[persistenceKey] {
              $0[persistenceKey] = (count + 1, reference)
              return reference
          } else {
            let reference = ValueReference(
              initialValue: value,
              persistenceKey: persistenceKey,
              fileID: fileID,
              line: line
            )
            $0[persistenceKey] = (1, reference)
            return reference
          }
        }
      }(),
      keyPath: \Value.self,
      onCancel: {
          print("🔥🔥🔥🔥🔥🔥🔥")
          print(value)
          @Dependency(PersistentReferencesKey.self) var references
          return references.withValue {
              if let (count, reference) = $0[persistenceKey] {
                  if count == 1 {
                      $0[persistenceKey] = nil
                  } else {
                      $0[persistenceKey] = (count - 1, reference)
                  }
                  return
              }
          }
      }
    )
  }

  public init<Wrapped>(
    _ persistenceKey: Persistence,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) where Value == Wrapped? {
    self.init(wrappedValue: nil, persistenceKey, fileID: fileID, line: line)
  }

  @_disfavoredOverload
  public init(
    _ persistenceKey: Persistence,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) throws {
    guard let initialValue = persistenceKey.load(initialValue: nil)
    else {
      throw LoadError()
    }
    self.init(wrappedValue: initialValue, persistenceKey, fileID: fileID, line: line)
  }
}

extension Shared {
  // NB: This initializer surfaces autocompletion of persistence keys to Xcode.
  public init(_: some PersistenceKey<Value>, _: Never) {
    fatalError()
  }
}

extension SharedReader {
  // NB: This initializer surfaces autocompletion of persistence keys to Xcode.
  public init(_: some PersistenceReaderKey<Value>, _: Never) {
    fatalError()
  }
}

private struct LoadError: Error {}

final class ValueReference<Value, Persistence>: Reference, @unchecked Sendable {
  private let lock = NSRecursiveLock()
  private let persistenceKey: Persistence?
  var persistence: Any? { self.persistenceKey }
  #if canImport(Combine)
    private let subject: CurrentValueRelay<Value>
  #endif
  private var subscription: Shared<Value, Persistence>.Subscription?
  private var _value: Value {
    didSet {
      self.subject.send(self._value)
    }
  }
  #if canImport(Perception)
    private let _$perceptionRegistrar = PerceptionRegistrar(
      isPerceptionCheckingEnabled: _isStorePerceptionCheckingEnabled
    )
  #endif
  private let fileID: StaticString
  private let line: UInt
  var value: Value {
    get {
      #if canImport(Perception)
        self._$perceptionRegistrar.access(self, keyPath: \.value)
      #endif
      return self.lock.withLock { self._value }
    }
    set {
      #if canImport(Perception)
        self._$perceptionRegistrar.willSet(self, keyPath: \.value)
        defer { self._$perceptionRegistrar.didSet(self, keyPath: \.value) }
      #endif
      self.lock.withLock {
        self._value = newValue
        func open<A>(_ key: some PersistenceKey<A>) {
          key.save(self._value as! A)
        }
        guard let key = self.persistenceKey as? any PersistenceKey
        else { return }
        open(key)
      }
    }
  }
  #if canImport(Combine)
    var publisher: AnyPublisher<Value, Never> {
      self.subject.dropFirst().eraseToAnyPublisher()
    }
  #endif
  init(
    initialValue: Value,
    persistenceKey: Persistence,
    fileID: StaticString,
    line: UInt
  ) where Persistence: PersistenceReaderKey<Value> {
    self._value = persistenceKey.load(initialValue: initialValue) ?? initialValue
    self.persistenceKey = persistenceKey
    #if canImport(Combine)
      self.subject = CurrentValueRelay(initialValue)
    #endif
    self.fileID = fileID
    self.line = line
    self.subscription = persistenceKey.subscribe(
      initialValue: initialValue
    ) { [weak self] value in
      guard let self else { return }
      #if canImport(Perception)
        self._$perceptionRegistrar.willSet(self, keyPath: \.value)
        defer { self._$perceptionRegistrar.didSet(self, keyPath: \.value) }
      #endif
      self.lock.withLock {
        self._value = value ?? initialValue
      }
    }
  }
  init(
    initialValue: Value,
    fileID: StaticString,
    line: UInt
  ) where Persistence == Any {
    self._value = initialValue
    self.persistenceKey = nil
    #if canImport(Combine)
      self.subject = CurrentValueRelay(initialValue)
    #endif
    self.fileID = fileID
    self.line = line
  }
  var description: String {
    "Shared<\(Value.self)>@\(self.fileID):\(self.line)"
  }
}

#if canImport(Observation)
  extension ValueReference: Observable {}
#endif
#if canImport(Perception)
  extension ValueReference: Perceptible {}
#endif

enum PersistentReferencesKey: DependencyKey {
    static var liveValue: LockIsolated<[AnyHashable: (Int, any Reference)]> {
    LockIsolated([:])
  }
  static var testValue: LockIsolated<[AnyHashable: (Int, any Reference)]> {
    LockIsolated([:])
  }
}
