variable "resource_group_name" {
   description = "Nombre del grupo de recursos en que se alojaran las VM y demas recursos creados"
   default     = "ResourceGroupCluster"
}

variable "location" {
   default = "UKWest"
   description = "Ubicación donse se alojaran los recursos creados"
}

variable "computer_name" {
   description = "Nombre de equipo de las VM"
   default     = "virtualMachine"
}

variable "admin_username" {
   description = "Nombre de usuario de las VM"
   default     = "administrador"
}

variable "admin_password" {
   description = "Contraseña para ingresar a los nombres de usuario"
}