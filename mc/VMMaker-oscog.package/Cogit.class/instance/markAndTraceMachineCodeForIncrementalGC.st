jit - api
markAndTraceMachineCodeForIncrementalGC
	"Free any methods that refer to unmarked objects, unlinking sends to freed methods."
	| pointer cogMethod |
	<var: #cogMethod type: #'CogMethod *'>
	objectMemory leakCheckIncrementalGC ifTrue:
		[self assert: self allMachineCodeObjectReferencesValid].
	codeModified := false.
	pointer := methodZone youngReferrers.
	[pointer < methodZone zoneEnd] whileTrue:
		[cogMethod := coInterpreter cCoerceSimple: (objectMemory longAt: pointer) to: #'CogMethod *'.
		 cogMethod cmRefersToYoung ifTrue:
			[self assert: (self cogMethodDoesntLookKosher: cogMethod) = 0.
			 self assert: (cogMethod cmType = CMMethod
						or: [cogMethod cmType = CMOpenPIC]).
			 (objectMemory isYoung: cogMethod selector) ifTrue:
				[objectMemory markAndTrace: cogMethod selector].
			 cogMethod cmType = CMMethod ifTrue:
				[(objectMemory isYoung: cogMethod methodObject) ifTrue:
					[objectMemory markAndTrace: cogMethod methodObject].
				self markYoungObjectsIn: cogMethod]].
		 pointer := pointer + BytesPerWord].
	objectMemory leakCheckIncrementalGC ifTrue:
		[self assert: self allMachineCodeObjectReferencesValid].
	codeModified ifTrue: "After updating oops in inline caches we need to flush the icache."
		[processor flushICacheFrom: methodZoneBase to: methodZone limitZony asInteger]