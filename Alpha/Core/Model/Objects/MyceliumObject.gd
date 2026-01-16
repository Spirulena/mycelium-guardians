extends ModelObject
class_name MyceliumObject

static var MyceliumState = {
	"Queue": "queue", ## cannot grow yet, but was asked by the player. This should not be mycelium object
	"Growing": "growing",
	"Idle": "idle",
	"ReleasingAcid": "releasing_acid",
	"Crashed": "crashed",
	"Thickening": "thickening",
	"Thickened": "thickened"
}

var _default_storage_limit: float
var _mycelium_gfx_index: int

func _init(coords, health = 1, myc_gfx_index: int = 0):
	super(GameTypes.Type.Mycelium, coords, health)
	_name = "Mycelium"
	_state = ModelObject.State.None
	_default_storage_limit = 0.5
	_mycelium_gfx_index = myc_gfx_index

## Thickening -> Thickened, Or ingore the state stransition, and just make it thickened.
## Presenter will only VFX when changing state. Now when is already set
func thicken():
	## Save that somehow, more then thickened at a time
	## we can be thickened and deepened. So timer to idle?
	## We want to lock other transitions  ?
	## Thats seems like something that should be in custom resource
	## So that we can change the game rules
	self.set_state(MyceliumObject.MyceliumState.Thickened)
