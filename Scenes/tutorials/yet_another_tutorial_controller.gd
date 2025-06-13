extends Node2D

@export var tutorial_enabled: bool = true

enum TutorialState {
	WHAT_ARE_WE,
	WHAT_ARE_WE_POST,
	CAMERA_MOVEMENT_1,
	BASIC_EXPLORE,
	BASIC_EXPLORE_EXIT,
	BASIC_EXPLORE_POST,
	BASIC_HARVEST,
	HARVEST_PAINT,
	HARVEST_PAINT_EXIT,
	BASIC_PRUNE,
	BASIC_PRUNE_POST,
	GROW_STRUCTURE_OUTLINE,
	GROW_STRUCTURE_SMOG,
	OVERLAY_SMOG,
	GROW_STRUCTURE_RADIATION,
	OVERLAY_RADIATION,
	GROW_STRUCTURE_STORAGE,
	GROW_STRUCTURE_STORAGE_POST,
	ACID_UPGRADE,
	ACID_UPGRADE_POST,
	FOREST_SEPARATION,
	FOREST_CREATION,
	INVEST_IN_FOREST,
	RECONNECT,
	TRADE,
	GROW_OVER_TECHNO,
	ACID_RELEASE,
	ACID_RELEASE_POST,
	HEAL_TILE,
	HEAL_STRUCTURE,
	OVERLAY_HEAL,
	HEAL_PAINT,
	GAME_SPEED,
	HIDE_TUTORIAL,
	GROW_SPORE_TOWER,
	SPORE_TOWER_PAUSE_PRODUCTION,
	RELEASE_SPORES,
	WORLD_MAP_OVERVIEW,
	FINISHED
}

# Define the next state for each current state
var state_transitions = {
	TutorialState.WHAT_ARE_WE: TutorialState.WHAT_ARE_WE_POST,
	TutorialState.WHAT_ARE_WE_POST: TutorialState.CAMERA_MOVEMENT_1,
	TutorialState.CAMERA_MOVEMENT_1: TutorialState.BASIC_EXPLORE,
	TutorialState.BASIC_EXPLORE: TutorialState.BASIC_EXPLORE_POST,
	TutorialState.BASIC_EXPLORE_POST: TutorialState.BASIC_EXPLORE_EXIT,
	TutorialState.BASIC_EXPLORE_EXIT: TutorialState.BASIC_HARVEST,
	TutorialState.BASIC_HARVEST: TutorialState.HARVEST_PAINT,
	TutorialState.HARVEST_PAINT: TutorialState.HARVEST_PAINT_EXIT,
	TutorialState.HARVEST_PAINT_EXIT: TutorialState.BASIC_PRUNE,
	TutorialState.BASIC_PRUNE: TutorialState.BASIC_PRUNE_POST,
	TutorialState.BASIC_PRUNE_POST: TutorialState.GROW_STRUCTURE_OUTLINE,
	TutorialState.GROW_STRUCTURE_OUTLINE: TutorialState.GROW_STRUCTURE_SMOG,
	# after smog, explain smog overlay, and how to access it.
	TutorialState.GROW_STRUCTURE_SMOG: TutorialState.OVERLAY_SMOG,
	TutorialState.OVERLAY_SMOG: TutorialState.GROW_STRUCTURE_RADIATION,
	TutorialState.GROW_STRUCTURE_RADIATION: TutorialState.OVERLAY_RADIATION,
	TutorialState.OVERLAY_RADIATION: TutorialState.GROW_STRUCTURE_STORAGE,
	TutorialState.GROW_STRUCTURE_STORAGE: TutorialState.GROW_STRUCTURE_STORAGE_POST,
	TutorialState.GROW_STRUCTURE_STORAGE_POST: TutorialState.ACID_UPGRADE,
	TutorialState.ACID_UPGRADE: TutorialState.ACID_UPGRADE_POST,
	TutorialState.ACID_UPGRADE_POST: TutorialState.FOREST_SEPARATION,
	TutorialState.FOREST_SEPARATION: TutorialState.FOREST_CREATION,
	TutorialState.FOREST_CREATION: TutorialState.RECONNECT,
	# Change trade. Maybe remove global trade, or at least hide it
	TutorialState.RECONNECT: TutorialState.TRADE,
	# Then select and pause trade, upgrade forest
	TutorialState.TRADE: TutorialState.GROW_OVER_TECHNO,
	TutorialState.GROW_OVER_TECHNO: TutorialState.ACID_RELEASE,
	TutorialState.ACID_RELEASE: TutorialState.ACID_RELEASE_POST,
	TutorialState.ACID_RELEASE_POST: TutorialState.HEAL_TILE,
	TutorialState.HEAL_TILE: TutorialState.HEAL_STRUCTURE,
	TutorialState.HEAL_STRUCTURE: TutorialState.OVERLAY_HEAL,
	TutorialState.OVERLAY_HEAL: TutorialState.HEAL_PAINT,
	TutorialState.HEAL_PAINT: TutorialState.GAME_SPEED,
	TutorialState.GAME_SPEED: TutorialState.HIDE_TUTORIAL,
	TutorialState.HIDE_TUTORIAL: TutorialState.GROW_SPORE_TOWER,
	TutorialState.GROW_SPORE_TOWER: TutorialState.SPORE_TOWER_PAUSE_PRODUCTION,
	TutorialState.SPORE_TOWER_PAUSE_PRODUCTION: TutorialState.RELEASE_SPORES,
	TutorialState.RELEASE_SPORES: TutorialState.WORLD_MAP_OVERVIEW,
	TutorialState.WORLD_MAP_OVERVIEW: TutorialState.FINISHED,

}

# for going to previous state
var inverse_state_transitions = {}

var state_title: Dictionary = {
	TutorialState.WHAT_ARE_WE: "Introduction: Meet the Collective",
	TutorialState.WHAT_ARE_WE_POST: "Becoming One: Merging with the Collective",
	TutorialState.CAMERA_MOVEMENT_1: "Getting Around: Camera Navigation",
	TutorialState.BASIC_EXPLORE: "Exploration Basics: Growing the Mycelial Network",
	TutorialState.BASIC_EXPLORE_POST: "Post-Exploration: Reflecting on Growth",
	TutorialState.BASIC_EXPLORE_EXIT: "Exiting Explore Mode: A Reminder",
	TutorialState.BASIC_HARVEST: "Resource Gathering: Basic Harvesting",
	TutorialState.HARVEST_PAINT: "Advanced Harvesting: Mass-Scale Collection",
	TutorialState.HARVEST_PAINT_EXIT: "Exiting Harvest Mode: A Reminder",
	TutorialState.BASIC_PRUNE: "Retraction: Basic Pruning of the Network",
	TutorialState.BASIC_PRUNE_POST: "Mastering Movement: Pruning and Shape-Shifting",
	TutorialState.GROW_STRUCTURE_OUTLINE: "Cultivating Foundations: Spawning Mycelial Structures",
	TutorialState.GROW_STRUCTURE_SMOG: "Specialized Mycelial Formation: The Smog Absorber",
	TutorialState.OVERLAY_SMOG: "Sensory Overlay: Visualizing Smog",
	TutorialState.GROW_STRUCTURE_RADIATION: "Adaptive Structures: Radiation Absorbers",
	TutorialState.OVERLAY_RADIATION: "Sensory Overlay: Visualizing Radiation",
	TutorialState.GROW_STRUCTURE_STORAGE: "Resource Management: Storage Structures",
	TutorialState.GROW_STRUCTURE_STORAGE_POST: "Storage Mechanics: Handling Surplus",
	TutorialState.ACID_UPGRADE: "Smog Absorber Upgrade: Transform Smog into Acid and Minerals",
	TutorialState.ACID_UPGRADE_POST: "Unlocking the Power of Acid: Resource Management and Application",
	TutorialState.FOREST_SEPARATION: "Initial Forest Formation",
	TutorialState.FOREST_CREATION: "Consolidating a Forest",
	TutorialState.INVEST_IN_FOREST: "Resource Investment in Forest",
	TutorialState.RECONNECT: "Re-establish Network Connection",
	TutorialState.TRADE: "Resource Exchange with Forest",
	TutorialState.GROW_OVER_TECHNO: "Overgrow the Technological Citadel of AI",
	TutorialState.ACID_RELEASE: "Acid Deployment: Reclaiming Nature",
	TutorialState.ACID_RELEASE_POST: "The Acid Test: Assessing the Impact",
	TutorialState.HEAL_TILE: "Mycelial Restoration: Healing Tiles",
	TutorialState.HEAL_STRUCTURE: "Structural Integrity: Repairing Mycelial Constructs",
	TutorialState.OVERLAY_HEAL: "Fungal Vision: Health Overlay",
	TutorialState.HEAL_PAINT: "Mycelial Healing Field: Mass Restoration",
	TutorialState.GAME_SPEED: "Game speed - time perception",
	TutorialState.HIDE_TUTORIAL: "Hide Tutorial",
	TutorialState.GROW_SPORE_TOWER: "Cultivate a Spore Tower - Pathway to Discovery",
	TutorialState.SPORE_TOWER_PAUSE_PRODUCTION: "Resource Allocation: Spore Tower Equilibrium",
	TutorialState.RELEASE_SPORES: "Disperse Spores - Search for New Habitats",
	TutorialState.WORLD_MAP_OVERVIEW: "Global Vision - The Grand Tapestry",
	TutorialState.FINISHED: "Concluding Tutorial - Your Odyssey Awaits",
}

var enter_intro_text = {
	TutorialState.WHAT_ARE_WE: "You're part of a symbiotic collective of fungi, algae, and bacteria. We've merged into a sentient super-organism, housed in an old building. Together, we have a mission—to bring life back to a barren world. Help us absorb the radiation and break down the smog outside our shell.",
	TutorialState.WHAT_ARE_WE_POST: "Within our core, we safeguard something valuable. It's time to extend our reach; troubling changes are occurring in the outside world.",
	TutorialState.CAMERA_MOVEMENT_1: "Let's get you accustomed to navigation—you're now part of a vastly different being, after all.",
	TutorialState.BASIC_EXPLORE: "Extend our mycelium network to explore and gather information. Think of it as our body and mind; it’s fluid and ever-changing.",
	TutorialState.BASIC_EXPLORE_POST: "We sense an unnatural, rhythmic vibration. Something artificial is nearby. Let's extend our network further to figure out what it is.",
	TutorialState.BASIC_HARVEST: "When you locate a resource, it's time to harvest it. We release enzymes to make the resource bio-available, not just for us, but for other organisms as well.",
	TutorialState.HARVEST_PAINT: "For larger-scale harvesting, you can use the Harvest Paint mode. This mode functions similarly to explore mode but focuses on harvesting resources.",
	TutorialState.BASIC_PRUNE: "To retract or move back, we prune our mycelial network. Doing so recovers most of the resources used to extend the mycelium. Prune areas where our presence is no longer needed.",
	TutorialState.BASIC_PRUNE_POST: "This is how we alter our form and move. We continually expand and prune, shaping and reshaping ourselves.",
	TutorialState.GROW_STRUCTURE_OUTLINE: "Our mycelial network has the ability to weave specialized structures from its strands. These aren't human-crafted buildings; they grow organically from our network. If resources are insufficient, their growth will pause until conditions are favorable.",
	TutorialState.GROW_STRUCTURE_SMOG: "The air is thick with smog, stifling the growth of other life forms. Our mycelial network is robust enough to reclaim this space. The Smog Absorber can cleanse an area, giving other life a chance to flourish. Let me demonstrate its effective radius.",
	TutorialState.OVERLAY_SMOG: "Placing a Smog Absorber alters our collective vision to show smog concentrations. A green reading of 0.0 signifies a smog-free zone, but any level above that can degrade the health of our mycelium and structures.",
	TutorialState.GROW_STRUCTURE_RADIATION: "In this radiation-rich environment, we've evolved to absorb and convert this harmful energy into usable energy. Growing Radiation Absorbers will not only help us harness this resource but also generate additional energy for our network.",
	TutorialState.OVERLAY_RADIATION: "This sensory overlay reveals radiation levels. The higher the level, the more harmful it is to all life forms.",
	TutorialState.GROW_STRUCTURE_STORAGE: "Our network is amassing a surplus of resources. Let's build storage structures to prepare for more challenging times.",
	TutorialState.GROW_STRUCTURE_STORAGE_POST: "Once storage is full, resource flow will be halted, pausing transfers to both the base and storage structures.",
	TutorialState.ACID_UPGRADE: "Storing smog isn't a long-term solution. We've devised a way to break it down into useful components. However, note that the process consumes some energy.",
	TutorialState.ACID_UPGRADE_POST: "From smog, we extract minerals and a unique enzyme we'll refer to as 'acid.' This will prove invaluable in reclaiming territory from the Technological Citadel.",
	TutorialState.FOREST_SEPARATION: "With a surplus of resources, we can form an independent forest. To do this, let's first separate a part of our mycelium network using the |Prune| mode.",
	TutorialState.FOREST_CREATION: "The separation creates an 'island' of mycelium. After outlining the island using Prune mode, exit the mode to allow the forest to form.",
	TutorialState.RECONNECT: "Once the forest is established, it's time to reconnect it to our main network. This way, we can kickstart its growth by transferring resources.",
	TutorialState.INVEST_IN_FOREST: "Even after the initial setup, we can pump more resources into the forest to accelerate its growth and strengthen it.",
	TutorialState.TRADE: "Now that the forest is grown, it will perform photosynthesis. We can trade water and minerals to the forest in exchange for Carbon. Should you run low on resources, you can pause the trade.",
	TutorialState.GROW_OVER_TECHNO: "Our mycelium can extend over the technological constructs built by the rogue AI.",
	TutorialState.ACID_RELEASE: "The time has come to weaken the AI's structures. We've synthesized enough acid for this purpose.",
	TutorialState.ACID_RELEASE_POST: "With the application of acid, we've begun dissolving the harmful structures, slowing down the AI and reclaiming this world.",
	TutorialState.HEAL_TILE: "Our mycelial strands may fray and weaken, especially in the inhospitable terrains we find ourselves in. Though we can self-heal to an extent, focused regrowth will sometimes be necessary.",
	TutorialState.HEAL_STRUCTURE: "Our mycelial constructs are not immune to the ravages of this world; they too can be affected by elements like radiation and smog. Fortunately, they can be restored.",
	TutorialState.OVERLAY_HEAL: "To better aid in your efforts, our Fungal Vision can provide a health overlay for the entire network. While we strive to evolve and offer more nuanced data, for now, you can view the general health of each tile and structure during Heal mode.",
	TutorialState.HEAL_PAINT: "For more extensive healing needs, you can employ our Healing Field technique to regenerate multiple tiles and structures in one smooth motion.",
	TutorialState.GAME_SPEED: "Our life operates on a different time scale, but we're running out of it. Speed up the in-game clock to make quicker progress.",
	TutorialState.HIDE_TUTORIAL: "You can always minimize the tutorial and return to it later.",
	TutorialState.GROW_SPORE_TOWER: "Let's cultivate a Spore Tower, a resource-intensive structure that will produce a multitude of spores.",
	TutorialState.SPORE_TOWER_PAUSE_PRODUCTION: "Producing spores is a resource-intensive task that can drain our reserves. Occasionally, it may be necessary to pause production to rebalance our ecosystem.",
	TutorialState.RELEASE_SPORES: "With a sufficient spore count, we can now disperse them across the globe in hopes of finding new fertile grounds. A new base awaits.",
	TutorialState.WORLD_MAP_OVERVIEW: "Having released the spores, you can now access the planetary overview. This will be your control center for future expansions and global strategies.",
	TutorialState.FINISHED: "The tutorial is complete. Now the real growth begins. Venture forth.",
}

# This could be with separate window for each action. Short text, what to do next
var enter_actions_text = {
	TutorialState.WHAT_ARE_WE: "Observe the central building; this is our core.",
	TutorialState.CAMERA_MOVEMENT_1: "Drag the screen with the 'Middle Mouse Button' or 'Alt+Left Click'. Alternatively, use the [W][S][A][D] keys.",
	TutorialState.BASIC_EXPLORE: "To extend the mycelium, select 'Explore' from the bottom menu or press [E]. Then click and drag where you want to grow.",
	TutorialState.BASIC_EXPLORE_EXIT: "To exit any mode or close any window or tool, press the |Select|[Q] button located at the bottom menu, the [ESC] key, or right-click. This is the universal way to go back or exit.",
	TutorialState.BASIC_HARVEST: "In the default |Select| mode, click the resource icon that appears above the tile.",
	TutorialState.HARVEST_PAINT: "To activate Harvest Paint mode, click the |Harvest| button on the bottom menu or press the [V] key. Then paint over the resources you wish to harvest.",
	TutorialState.HARVEST_PAINT_EXIT: "To exit any mode or close any window or tool, press the |Select|[Q] button located at the bottom menu, the [ESC] key, or right-click. This is the universal way to go back or exit.",
	TutorialState.BASIC_PRUNE: "To start pruning, click the |Prune| button in the bottom menu or press the [Z] key. Then paint over the mycelium you wish to harvest.",
	TutorialState.GROW_STRUCTURE_OUTLINE: "Access the 'Grow Structures' option from the bottom menu or press the [F] key. Hover over each structure icon to see its resource requirements. [b]Note:[/b] While in this menu, the [W][S][A][D] keys will not navigate the camera; they are repurposed for selecting structures. Use the mouse for camera navigation.",
	TutorialState.GROW_STRUCTURE_SMOG: "To grow the Smog Absorber, click the |Grow Structures| button in the bottom menu, or hit the [F] key. Navigate to the 'Absorbers' category either by clicking or using the [1][2][3] keys. To choose the structure, click its name or use the [Q][W][E][R] keys. [b]Note:[/b] While in this menu, the [W][S][A][D] keys are disabled for camera navigation. Select 'Smog' and choose a location for the structure to grow; it must sprout from an existing mycelium tile.",
	TutorialState.OVERLAY_SMOG: "Access Smog Overlay from Fungal Menu on the left side, the one with lungs icon. We try to use symbols you human will relate to. Hit 'Fungal Vision' button, hit [ESC] key or right click to go out of any Fungal Vision overlay",
	TutorialState.GROW_STRUCTURE_RADIATION: "Grow structure 'Radiation Absorber'. Click on |Grow Structures| button in bottom menu. Or hit [F] key. Select category by clicking or using [1][2][3] keys, Select [b]'Absorbers'[/b]. To select structure click on name or use [Q][W][E][R] keys, Select [b]'Radiation'[/b]. Select where the structure should grow. We can only grow on top of one of the mycelium tiles",
	TutorialState.OVERLAY_RADIATION: "Access Smog Overlay from Fungal Menu on the left side, the one with bio-hazard icon. We try to use symbols you human will relate to. Hit 'Fungal Vision' button, hit [ESC] key or right click to go out of any Fungal Vision overlay",
	TutorialState.GROW_STRUCTURE_STORAGE: "Grow all storage structures, one of each type. H2O, Energy, Minerals, Carbon",
	TutorialState.ACID_UPGRADE: "Choose a Smog Absorber and click the 'Upgrade' button above it to see the cost and benefits. Confirm the upgrade by clicking 'Confirm'. Remember, this process will consume energy.",
	TutorialState.ACID_UPGRADE_POST: "Monitor the levels of Smog, Acid, and Energy in the top-left corner of the screen.",
	TutorialState.FOREST_SEPARATION: "Activate Prune Mode and separate a portion of the mycelium network from the main base. Once done, exit Prune mode.",
	TutorialState.FOREST_CREATION: "Above the separated island, a 'Create Forest' icon will appear. Click it to establish a new forest.",
	TutorialState.RECONNECT: "Use 'Explore' mode to reconnect the forest back to the main mycelium network.",
	TutorialState.INVEST_IN_FOREST: "Click on a mycelium tile that belongs to a forest to see its interface, shaped like a tree with two buttons. One button enables you to send additional resources to the forest. Once the forest is fully grown, the interface will indicate its complete state.",
	TutorialState.TRADE: "In the forest interface, you can pause or resume the resource trade with the forest. More advanced interactions may become available as we develop a common language with the forest.",
	TutorialState.GROW_OVER_TECHNO: "Switch to 'Explore' mode and grow over the AI's technological panels. You'll see our mycelium covering them.",
	TutorialState.ACID_RELEASE: "Switch to 'Acid' mode. Paint over the technological structures already covered by mycelium. This will dissolve them, allowing us to harvest their resources.",
	TutorialState.ACID_RELEASE_POST: "The acid has successfully curtailed the AI's expansion and is helping us reclaim the land.",
	TutorialState.HEAL_TILE: "In the default 'Select' mode, click on a mycelium tile to open its 'Soil Details' panel on the left. If the health is below optimal levels, click 'Heal' to initiate regrowth.",
	TutorialState.HEAL_STRUCTURE: "In 'Select' mode, click on any of our mycelial constructs. If its structural integrity is compromised, initiate a 'Heal' action from the bottom right panel.",
	TutorialState.OVERLAY_HEAL: "The health overlay can be accessed from the 'Fungal Vision' menu, located at the left-center of the interface.",
	TutorialState.HEAL_PAINT: "Activate 'Heal' Mode and click and drag across the network to restore multiple tiles and structures. The Health Overlay will also be activated for your convenience.",
	TutorialState.GAME_SPEED: "Increase the game speed through the [b]Speed[/b] options menu.",
	TutorialState.HIDE_TUTORIAL: "To hide the tutorial, click on the minimize button. Focus on resource gathering, then return by selecting |<< Tutorial|, located on the right side of the screen.",
	TutorialState.GROW_SPORE_TOWER: "Initiate the growth of a Spore Tower. Once fully developed, activate spore production using the button atop the tower. Aim to accumulate at least one million spores.",
	TutorialState.SPORE_TOWER_PAUSE_PRODUCTION: "Navigate to the Spore Tower within your network. In the structure details panel on the right, you'll find an option to 'Pause Production.' Use this to temporarily halt spore generation and conserve resources.",
	TutorialState.RELEASE_SPORES: "Select the Spore Tower and then click the 'Release' button above. This will liberate the accumulated spores into the atmosphere.",
	TutorialState.WORLD_MAP_OVERVIEW: "Open the planetary view using the button at the bottom left. Track the journey of your spores; once they find a new habitat, we can establish another outpost.",
	TutorialState.FINISHED: "Your path is clear. Foster life on this desolate planet, reclaiming what has been lost and annihilated.",
}

var enter_state_callable = {
	TutorialState.FINISHED: self.enter_finished_state,
}

var exit_state_callable = {
}

@export var tutorial_state: TutorialState = TutorialState.WHAT_ARE_WE
# todo load this from a saved state
var prune_tile_index = 824
var island_index: int = -1
var forest_index: int = -1

func _ready():
	#Events.level_loaded.connect(start_tutorial)
	_init_inverse_state()
	#Events.spore_production_reached_target.connect(_on_spore_production_reached_target)

func _init_inverse_state():
	for state in state_transitions.keys():
		var next_state = state_transitions[state]
		inverse_state_transitions[next_state] = state

func start_tutorial():
	# TODO: change that, signal's gone
	#await Events.intro_screen_closed
	tutorial_enabled = true

	#Events.tutorial_next_page_requested.connect(_on_tutorial_next_page_requested)
	#Events.tutorial_prev_page_requested.connect(_on_tutorial_prev_page_requested)
#
	#Events.exit_tutorial_request.connect(_on_exit_tutorial_request)
	enter_state(tutorial_state)

func _on_spore_production_reached_target():
	# this should be in tutorial controller, reacting to the above signal
	var text = "You made it! We made it! No we will release all of these spores and hope for the best. Hopefully we will find a new location. The location. Thanks for playing the demo!"
	var title = "Congratulations"
	# TODO: need to do it differently
	#Events.set_tutorial_instructions_window.emit(text, title, "blank")
	#await Events.tutorial_instructions_window_closed

func _on_tutorial_next_page_requested():
	go_to_next_state()

func _on_tutorial_prev_page_requested():
	go_to_previous_state()

func _on_exit_tutorial_request():
	# TODO: confirmation window 1st
	exit_tutorial()

func exit_tutorial():
	tutorial_enabled = false
	#Events.show_all_bottom_menu_buttons.emit()

	# disconnect next previous buttons ?
	# don't need to as it is not visible

func enter_state(new_state):
	tutorial_state = new_state

	if enter_state_callable.has(new_state):
		enter_state_callable[new_state].call()
	generic_enter_state_action()

func exit_state(old_state):
	if exit_state_callable.has(old_state):
		exit_state_callable[old_state].call()
	# generic_exit_state_action()

# What about simple like in Particle Fleet,
# Where can just click next and go to next step, and can go back
# not sure it was checking what player did, before allowing to go to next action
# Could have previous / next for someone to go back and read.
# or access to tutorial instructions in that book fashion
# accessible from pause menu

# Function to transition to the next state
func go_to_next_state():
	var old_state = tutorial_state

	if state_transitions.has(old_state):
		var new_state = state_transitions[old_state]
		exit_state(old_state)  # Exiting the current state
		enter_state(new_state)  # Entering the new state
	else:
		print("Tutorial complete, or no next state defined.")
		# Handle the end of the tutorial here, if necessary
		# Events.tutorial_finished.emit("forest_island")

func go_to_previous_state():
	var old_state = tutorial_state

	if inverse_state_transitions.has(old_state):
		var new_state = inverse_state_transitions[old_state]
		exit_state(old_state)  # Exiting the current state
		enter_state(new_state)  # Entering the new (previous) state
		tutorial_state = new_state  # Update the tutorial_state
	else:
		print("At the beginning of the tutorial or no previous state.")
		# Handle the beginning of the tutorial here, if necessary

func generic_enter_state_action():
	var title = str(TutorialState.keys()[tutorial_state])
	if  title.contains("_POST"):
		title = title.replace("_POST", "...")
	if state_title.has(tutorial_state):
		title = state_title[tutorial_state]
	var intro_text = ""
	if enter_intro_text.has(tutorial_state):
		intro_text = enter_intro_text[tutorial_state]
	var action_text = ""
	if enter_actions_text.has(tutorial_state):
		action_text = enter_actions_text[tutorial_state]
	# state_name used to lookup gif
	var state_name = str(TutorialState.keys()[tutorial_state])
	# TODO: need to pass it differently
	#Events.set_tutorial_instructions_window.emit(intro_text, title, state_name, action_text)

func enter_finished_state():
	var text = "We need to find new place for a colony, it does not seems to be a friendly neighborhood. For that build a spore tower, produce million of millions of gazillion of spores, no worries I'll let you know once we have enough, i'll keep the score. Then we will release them all at once and hope they will find a new `safe` location"
	var title = "The goal"
	# TODO: need to do differently
	#Events.set_tutorial_instructions_window.emit(text, title)
	#await Events.tutorial_instructions_window_closed
#
	#Events.tutorial_enable_degradation.emit()
	#Events.show_all_bottom_menu_buttons.emit()
	go_to_next_state()
