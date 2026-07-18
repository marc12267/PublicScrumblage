extends HealthManager

func decrease_health(val):
	stat_controller.set_base_stat("HealthManager.health",health-1)
