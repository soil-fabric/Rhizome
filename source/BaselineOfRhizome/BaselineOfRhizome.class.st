Class {
	#name : 'BaselineOfRhizome',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfRhizome',
	#package : 'BaselineOfRhizome'
}

{ #category : 'baselines' }
BaselineOfRhizome >> baseline: spec [
	<baseline>
	self pharoDevs: spec.
	spec
		for: #common
		do: [ 
			self 
				gossip: spec;
				murmur3: spec;
				soil: spec;
				zinc: spec.
			"Rhizome-Core is the model and requires nothing. Everything that needs an
			outside project sits beside it in a package of its own, so an image can
			take the model - and discovery on top of it - without taking Soil, Zinc
			or murmur3 along."
			spec
				package: 'Rhizome-Core';
				package: 'Rhizome-Placement' with: [ spec requires: #('Rhizome-Core' 'NonCryptographicHashes') ];
				package: 'Rhizome-Soil' with: [ spec requires: #('Rhizome-Core' 'Soil') ];
				package: 'Rhizome-Endpoints' with: [ spec requires: #('Rhizome-Core' 'ZincHTTPComponents') ];
				package: 'Rhizome-Discovery' with: [ spec requires: #('Rhizome-Core' 'Gossip') ];
				package: 'Rhizome-Discovery-Tests' with: [ spec requires: #('Rhizome-Discovery' 'GossipTests' 'PharoDEVS') ];
				package: 'Rhizome-Simulator' with: [ spec requires: #('Rhizome-Core' 'Rhizome-Endpoints' 'PharoDEVS') ];
				package: 'Rhizome-Tests' with: [ spec requires: #('Rhizome-Core' 'Rhizome-Placement' 'Rhizome-Soil' 'Rhizome-Endpoints' 'Rhizome-Simulator') ].

			spec
				group: 'default' with: #('All');
				group: 'Model' with: #('Rhizome-Core');
				"The discovery an image runs: the model and the discovery on top of it,
				and no tests. It used to carry Rhizome-Discovery-Tests as well, and that
				package requires PharoDEVS - so asking for discovery put a simulator in
				the image. The tests have a group of their own now, and its name says so."
				group: 'Discovery' with: #('Rhizome-Core' 'Rhizome-Discovery');
				group: 'DiscoveryTests' with: #('Discovery' 'Rhizome-Discovery-Tests');
				group: 'All' with: #('Rhizome-Core' 'Rhizome-Placement' 'Rhizome-Soil' 'Rhizome-Endpoints'
					'Rhizome-Discovery' 'Rhizome-Discovery-Tests' 'Rhizome-Simulator' 'Rhizome-Tests') ]
]

{ #category : 'as yet unclassified' }
BaselineOfRhizome >> gossip: spec [
	"Pinned, not following main: an image that ships has to be determined by what is
	written down. Two builds of one apptive-common commit were getting different
	Gossip, which for a protocol spoken between images is the drift nobody looks for.

	The runtime group rather than Gossip's default, which is Core plus Simulation
	and brings both test packages - and with Gossip-Simulation-Tests, PharoDEVS.
	Rhizome-Discovery-Tests reaches for DevsGossiper, and that lives in the Gossip
	package itself, so the tests here lose nothing by it."

	spec baseline: 'Gossip' with: [ 
		spec 
			repository: 'github://soil-fabric/Gossip:797298051a2554c4cf68d59c4e8148472b4b5aab/source';
			loads: #('Runtime') ].
	"And the test side, for the one package here that tests against gossip:
	GossipManualClock is a test double and lives in Gossip-Tests, which the
	runtime group deliberately leaves out. Declared as a project of its own so
	that asking for the tests cannot quietly put them in a deployed image."
	spec
		project: 'GossipTests' copyFrom: 'Gossip' with: [ 
			spec loads: #('Core') ]
]

{ #category : 'as yet unclassified' }
BaselineOfRhizome >> murmur3: spec [ 
	spec baseline: 'NonCryptographicHashes' with: [ 
		spec 
			repository: 'github://ApptiveGrid/pharo-non-cryptographic-hashes:master/src' ]
]

{ #category : 'as yet unclassified' }
BaselineOfRhizome >> pharoDevs: spec [

	spec
		baseline: 'PharoDEVS' with: [ 
			spec 
				repository: 'github://soil-fabric/PharoDEVS:main/source' ]
]

{ #category : 'accessing' }
BaselineOfRhizome >> soil: spec [
	"Pinned, for the same reason as Gossip: a build has to be determined by what is
	written down. Following main meant this build changed whenever Soil did, and
	because no group is named, Soil's own tests come along and run here - so Rhizome
	went red on 2026-09-24 at SoilResidentTest>>testProcessRestartsStopAtTheLimit, a
	test nobody here wrote, over a change nobody here made.

	The commit is the one apptive-common pins. That is the Soil this ecosystem
	runs, and naming the same one means the two cannot ask for different Soils of
	the same project - which Metacello would settle by load order rather than by
	anybody's decision.

	The group is deliberately still open. Rhizome-Soil is about Soil, so what it
	needs is more than a runtime group; narrowing it is a question of its own, and
	pinning answers the one that was asked."

	spec baseline: 'Soil' with: [ 
		spec 
			repository: 'github://ApptiveGrid/Soil:b4f26946a57c1bb5fa15fc5abeaab9f096c4e231/src' ]
]

{ #category : 'baselines' }
BaselineOfRhizome >> zinc: spec [
	spec baseline: 'ZincHTTPComponents' with: [ 
		spec 
			loads: #('REST' 'WebSocket');
			repository: 'github://svenvc/zinc/repository']
]
