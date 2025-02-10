extends Area3D

func _on_body_entered(body):
	print("Key Found!")
	queue_free()
