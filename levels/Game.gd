extends Node2D

var remaning_blocks := 0

func _ready() -> void:
	var blocks := get_tree().get_nodes_in_group("blocks")
	remaning_blocks = blocks.size()
	print(remaning_blocks)
	
	for block: Block in blocks:
		block.tree_exited.connect(func() -> void:
			remaning_blocks -= 1
			print(remaning_blocks)
			if remaning_blocks == 0:
				print("game over")
			)
