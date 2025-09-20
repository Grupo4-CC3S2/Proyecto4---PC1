@test "Robustez: limpieza al detener servicio via systemctl" {
  sudo systemctl stop pc14app.service

  run sudo journalctl -u pc14app.service --no-pager -n 20
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Limpieza completada" ]]
}