-- QUERYS GERAL
vRP.prepare("vRP/create_user","INSERT INTO vrp_users(whitelist) VALUES(false); SELECT LAST_INSERT_ID() AS id")
vRP.prepare("vRP/add_identifier","INSERT INTO vrp_user_ids(identifier,user_id) VALUES(@identifier,@user_id)")
vRP.prepare("vRP/userid_byidentifier","SELECT user_id FROM vrp_user_ids WHERE identifier = @identifier")
vRP.prepare("vRP/get_all_licenses","SELECT * FROM vrp_user_ids WHERE user_id = @user_id")
vRP.prepare("vRP/set_userdata","REPLACE INTO vrp_user_data(user_id,dkey,dvalue) VALUES(@user_id,@key,@value)")
vRP.prepare("vRP/get_userdata","SELECT dvalue FROM vrp_user_data WHERE user_id = @user_id AND dkey = @key")
vRP.prepare("vRP/set_srvdata","REPLACE INTO vrp_srv_data(dkey,dvalue) VALUES(@key,@value)")
vRP.prepare("vRP/get_srvdata","SELECT dvalue FROM vrp_srv_data WHERE dkey = @key")
vRP.prepare("vRP/del_srvdata","DELETE FROM vrp_srv_data WHERE dkey = @dkey")
vRP.prepare("vRP/get_whitelisted","SELECT whitelist FROM vrp_users WHERE id = @user_id")
vRP.prepare("vRP/set_whitelisted","UPDATE vrp_users SET whitelist = @whitelist WHERE id = @user_id")
vRP.prepare("vRP/set_last_login","UPDATE vrp_users SET ultimo_login = @ultimo_login, ip = @ip WHERE id = @user_id")

-- CREATE CHARACTER
vRP.prepare("vRP/get_all_users","SELECT * FROM vrp_users WHERE id = @id")
vRP.prepare("vRP/get_controller","SELECT controller FROM vrp_users_infos WHERE user_id = @user_id")
vRP.prepare("vRP/set_controller","UPDATE vrp_users_infos SET controller = @controller, rosto = @rosto WHERE user_id = @user_id")
vRP.prepare("vRP/get_rosto","SELECT rosto FROM vrp_users_infos WHERE user_id = @user_id")

-- USER IDENTITIES
vRP.prepare("vRP/update_multas","UPDATE vrp_user_identities SET multas = @multas WHERE user_id = @user_id")
vRP.prepare("vRP/update_banco","UPDATE vrp_user_identities SET banco = @banco WHERE user_id = @user_id")

-- USER INFOS
vRP.prepare("vRP/init_users_infos","INSERT IGNORE INTO vrp_users_infos(user_id) VALUES(@user_id)")
vRP.prepare("vRP/get_users_infos","SELECT * FROM vrp_users_infos WHERE user_id = @user_id")
vRP.prepare("vRP/set_roupas","UPDATE vrp_users_infos SET roupas = @roupas WHERE user_id = @user_id")
vRP.prepare("vRP/set_tattos","UPDATE vrp_users_infos SET tattos = @tattos WHERE user_id = @user_id")

-- FACTIONS
vRP.prepare("vRP/get_factions","SELECT * FROM mirtin_orgs WHERE org = @faction")
vRP.prepare("vRP/update_chest_factions","UPDATE mirtin_orgs SET bau = @bau WHERE org = @faction")
vRP.prepare("vRP/update_armazem","UPDATE mirtin_orgs SET armazem = @armazem WHERE org = @faction")

-- PORTA MALAS
vRP.prepare("vRP/get_portaMalas","SELECT portamalas FROM vrp_user_veiculos WHERE user_id = @user_id AND veiculo = @veiculo")
vRP.prepare("vRP/update_portaMalas","UPDATE vrp_user_veiculos SET portamalas = @portamalas WHERE user_id = @user_id AND veiculo = @veiculo")

-- TUNAGENS
vRP.prepare("vRP/update_tuning","UPDATE vrp_user_veiculos SET tunagem = @tunagem WHERE user_id = @user_id AND veiculo = @veiculo")

-- SISTEMA DE EMPRESAS
vRP.prepare("eMP/get_estoque","SELECT estoque FROM vrp_empresas WHERE id = @id")
vRP.prepare("eMP/add_estoque","UPDATE vrp_empresas SET estoque = @estoque WHERE id = @id")
vRP.prepare("eMP/get_cofre","SELECT cofre FROM vrp_empresas WHERE id = @id")
vRP.prepare("eMP/update_cofre","UPDATE vrp_empresas SET cofre = @cofre WHERE id = @id")
vRP.prepare("eMP/get_owner","SELECT proprietario FROM vrp_empresas WHERE id = @id")
vRP.prepare("eMP/add_owner","UPDATE vrp_empresas SET proprietario = @proprietario, nome = @nome WHERE id = @id")
vRP.prepare("eMP/get_name","SELECT nome FROM vrp_empresas WHERE id = @id")
vRP.prepare("eMP/get_prop","SELECT * FROM vrp_empresas WHERE proprietario = @id")

-- CONCESSIONARIA
vRP.prepare("vRP/inserir_veh","INSERT INTO vrp_user_veiculos(user_id,veiculo,placa,ipva, expired) VALUES(@user_id,@veiculo,@placa,@ipva,@expired)")
vRP.prepare("vRP/delete_vehicle","DELETE FROM vrp_user_veiculos WHERE user_id = @user_id AND veiculo = @veiculo")
vRP.prepare("vRP/get_stock","SELECT COUNT(veiculo) as quantidade FROM vrp_user_veiculos WHERE veiculo = @veiculo")
vRP.prepare("vRP/selecionar_veiculos","SELECT * FROM vrp_user_veiculos")
vRP.prepare("vRP/get_plate_id","SELECT user_id FROM vrp_user_veiculos WHERE placa = @placa")

-- GARAGEM
vRP.prepare("vRP/getAllVehicles","SELECT * FROM vrp_user_veiculos")
vRP.prepare("vRP/get_Veiculos","SELECT * FROM vrp_user_veiculos WHERE user_id = @user_id")
vRP.prepare("vRP/update_veiculo_status","UPDATE vrp_user_veiculos SET motor = @motor, lataria = @lataria, gasolina = @gasolina WHERE user_id = @user_id and veiculo = @veiculo")
vRP.prepare("vRP/count_veiculos","SELECT COUNT(veiculo) as quantidade FROM vrp_user_veiculos WHERE user_id = @user_id")
vRP.prepare("vRP/get_tunagem","SELECT tunagem FROM vrp_user_veiculos WHERE user_id = @user_id AND veiculo = @veiculo")
vRP.prepare("vRP/get_veiculos_status","SELECT * FROM vrp_user_veiculos WHERE user_id = @user_id AND veiculo = @veiculo")
vRP.prepare("vRP/set_status","UPDATE vrp_user_veiculos SET status = @status WHERE user_id = @user_id AND veiculo = @veiculo")
vRP.prepare("vRP/set_ipva","UPDATE vrp_user_veiculos SET ipva = @ipva WHERE user_id = @user_id AND veiculo = @veiculo")
vRP.prepare("vRP/update_owner_vehicle","UPDATE vrp_user_veiculos SET user_id = @nuser_id WHERE user_id = @user_id AND veiculo = @veiculo")

-- SISTEMA DE LOJA
vRP.prepare("vRP/select_payments","SELECT * FROM pagamentos WHERE hash = @hash")
vRP.prepare("vRP/update_payments","UPDATE pagamentos SET activated = @activated, user_id = @user_id WHERE hash = @hash")
vRP.prepare("vRP/update_coins","UPDATE vrp_users_infos SET coins = @coins WHERE user_id = @user_id")
vRP.prepare("vRP/update_vip","UPDATE vrp_users_infos SET vip = @vip WHERE user_id = @user_id")
vRP.prepare("vRP/update_prioridade","UPDATE vrp_users_infos SET prioridade = @prioridade WHERE user_id = @user_id")

-- HOMES
vRP.prepare("vRP/getAllProps","SELECT * FROM vrp_propriedades")
vRP.prepare("vRP/getAllPropId","SELECT * FROM vrp_propriedades WHERE id = @id")
vRP.prepare("vRP/getPropUserID","SELECT * FROM vrp_propriedades WHERE proprietario = @proprietario")
vRP.prepare("vRP/createProp","INSERT INTO vrp_propriedades(coords,price,infoProps,permissao) VALUES(@coords,@price,@infoProps,@permissao)")
vRP.prepare("vRP/deleteProp","DELETE FROM vrp_propriedades WHERE id = @id")
vRP.prepare("vRP/updateOwner","UPDATE vrp_propriedades SET proprietario = @proprietario WHERE id = @id")
vRP.prepare("vRP/updateMorador","UPDATE vrp_propriedades SET moradores = @moradores WHERE id = @id")
vRP.prepare("vRP/updateIptu","UPDATE vrp_propriedades SET iptu = @iptu WHERE id = @id")
vRP.prepare("vRP/lockProp","UPDATE vrp_propriedades SET infoProps = @infoProps WHERE id = @id")
vRP.prepare("vRP/wipeHouse","UPDATE vrp_propriedades SET proprietario = @proprietario, moradores = @moradores, bau = @bau, armario = @armario, iptu = @iptu WHERE id = @id")
vRP.prepare("vRP/updateArmario","UPDATE vrp_propriedades SET armario = @armario WHERE id = @id")

-- INVENTARIO
vRP.prepare("vRP/inv_tmpchest", "SELECT * FROM vrp_srv_data WHERE `dkey` LIKE '%tmpChest:%'")
vRP.prepare("vRP/inv_deltmpchest", "DELETE FROM vrp_srv_data WHERE `dkey` LIKE '%tmpChest:%'")

-- VIPS
vRP.prepare("vRP/select_bonus","SELECT bonus FROM vrp_users_infos WHERE user_id = @user_id")
vRP.prepare("vRP/update_bonus","UPDATE vrp_users_infos SET bonus = @bonus WHERE user_id = @user_id")
vRP.prepare("vRP/getNumber","SELECT telefone FROM vrp_user_identities WHERE telefone = @telefone")
vRP.prepare("vRP/getRegistro","SELECT registro FROM vrp_user_identities WHERE registro = @registro")
vRP.prepare("vRP/update_number","UPDATE vrp_user_identities SET telefone = @telefone WHERE user_id = @user_id")
vRP.prepare("vRP/update_registro","UPDATE vrp_user_identities SET registro = @registro WHERE user_id = @user_id")
vRP.prepare("vRP/getPlate","SELECT placa FROM vrp_user_veiculos WHERE placa = @placa")
vRP.prepare("vRP/update_plate","UPDATE vrp_user_veiculos SET placa = @placa WHERE user_id = @user_id AND veiculo = @veiculo")
vRP.prepare("vRP/update_garagem","UPDATE vrp_users_infos SET garagem = @garagem WHERE user_id = @user_id")

-- FICHA CRIMINAL
vRP.prepare("vRP/add_criminal","UPDATE vrp_user_identities SET criminal = @criminal WHERE user_id = @user_id")