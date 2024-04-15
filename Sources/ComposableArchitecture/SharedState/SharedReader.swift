#if canImport(Combine)
import Combine
#endif

@dynamicMemberLookup
@propertyWrapper
public struct SharedReader<Value, Persistence> {
    class ReferenceClass {
        let onCancel: () -> Void
        init(onCancel: @escaping () -> Void) {
            self.onCancel = onCancel
        }

        deinit {
            onCancel()
        }
    }

    private let refClass: ReferenceClass
  fileprivate let reference: any Reference
  fileprivate let keyPath: AnyKeyPath

    init(reference: any Reference, keyPath: AnyKeyPath, onCancel: @escaping () -> Void) {
    self.reference = reference
    self.keyPath = keyPath
        self.refClass = .init(onCancel: onCancel)
  }

  init(reference: some Reference<Value>) {
      self.init(reference: reference, keyPath: \Value.self, onCancel: {})
  }

  public init(projectedValue: SharedReader) {
    self = projectedValue
  }

  public init(_ value: Value, fileID: StaticString = #fileID, line: UInt = #line)
  where Persistence == Any {
    self.init(
      reference: ValueReference(
        initialValue: value,
        fileID: fileID,
        line: line
      ),
      keyPath: \Value.self,
      onCancel: {}
    )
  }

  public var wrappedValue: Value {
    func open<Root>(_ reference: some Reference<Root>) -> Value {
      reference.value[
        keyPath: unsafeDowncast(self.keyPath, to: KeyPath<Root, Value>.self)
      ]
    }
    return open(self.reference)
  }

  public var projectedValue: Self {
    get { self }
  }

  public subscript<Member>(
    dynamicMember keyPath: KeyPath<Value, Member>
  ) -> SharedReader<Member, Any> {
    SharedReader<Member, Any>(
      reference: self.reference,
      keyPath: self.keyPath.appending(path: keyPath)!,
      onCancel: {}
    )
  }

  public subscript<Member>(
    dynamicMember keyPath: KeyPath<Value, Member?>
  ) -> SharedReader<Member, Any>? {
    guard let initialValue = self.wrappedValue[keyPath: keyPath]
    else { return nil }
    return SharedReader<Member, Any>(
      reference: self.reference,
      keyPath: self.keyPath.appending(
        path: keyPath.appending(path: \.[default:DefaultSubscript(initialValue)])
      )!,
      onCancel: {}
    )
  }

#if canImport(Combine)
  public var publisher: AnyPublisher<Value, Never> {
    func open<R: Reference>(_ reference: R) -> AnyPublisher<Value, Never> {
      return reference.publisher
        .compactMap { $0[keyPath: self.keyPath] as? Value }
        .eraseToAnyPublisher()
    }
    return open(self.reference)
  }
#endif
}

public typealias AnySharedReader<Value> = SharedReader<Value, Any>

extension SharedReader where Persistence: PersistenceReaderKey<Value> {
  public var persistence: Persistence {
    self.reference.persistence! as! Persistence
  }
}

extension SharedReader: @unchecked Sendable where Value: Sendable {}

extension SharedReader: Equatable where Value: Equatable {
  public static func == (lhs: SharedReader, rhs: SharedReader) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension SharedReader: Hashable where Value: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.wrappedValue)
  }
}

extension SharedReader: Identifiable where Value: Identifiable {
  public var id: Value.ID {
    self.wrappedValue.id
  }
}

extension SharedReader: Encodable where Value: Encodable {
  public func encode(to encoder: Encoder) throws {
    do {
      var container = encoder.singleValueContainer()
      try container.encode(self.wrappedValue)
    } catch {
      try self.wrappedValue.encode(to: encoder)
    }
  }
}

extension SharedReader: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self.wrappedValue
  }
}

extension SharedReader
where Value: RandomAccessCollection & MutableCollection, Value.Index: Hashable & Sendable {
  /// Derives a collection of read-only shared elements from a read-only shared collection of
  /// elements.
  ///
  /// See the documentation for [`@Shared`](<doc:Shared>)'s ``Shared/elements`` for more
  /// information.
  public var elements: some RandomAccessCollection<SharedReader<Value.Element, Any>> {
    zip(self.wrappedValue.indices, self.wrappedValue).lazy.map { index, element in
      self[index, default: DefaultSubscript(element)]
    }
  }
}

extension SharedReader {
  public func eraseToAnySharedReader() -> AnySharedReader<Value> {
    self[dynamicMember: \.self]
  }
}
