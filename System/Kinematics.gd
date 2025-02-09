class_name Kinematics

static func dampf(a : float, b : float, lambda : float, delta : float) -> float:
	return lerpf(a,b,1.0-exp(-lambda*delta))

static func damp(a, b, lambda : float, delta : float):
	return lerp(a,b,1.0-exp(-lambda*delta))
