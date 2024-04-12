/// A macro that produces two methods:
/// 
/// - 'makeRandom' to generate an instance of the type with random values
/// - 'makeRandomWith()' adds the possibility to stub values
@attached(extension, conformances: Randomizable, names: named(makeRandom), named(makeRandomWith))
public macro Randomizable() = #externalMacro(module: "RandomizableMacros", type: "RandomizableMacro")
