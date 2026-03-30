const mySlots = 50;
const inSlots = 100;

let shiftPressed = false;

/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* INIT */
/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
$(document).ready(function () {
	window.addEventListener("message", function (event) {

		switch (event.data.action) {
			case "hideMenu":
				$(".inventory").css("display", "none")
			break;

			case "showMenu":
				updateMochila();
				$(".use").css("display","block")
				$(".send").css("display","block")
				$(".inventory").css("display", "flex")
				$(".myInfos2").html("");
				$(".amount").val(0);
			break;

			case "updateMochila":
				updateMochila();
			break;

			case "showVehicles":
				requestVehicles();
				$(".use").css("display","none")
				$(".send").css("display","none")
				$(".inventory").css("display","flex")
				$(".myInfos2").html("");
				$(".amount").val(0);
			break;

			case "updateVehicles":
				requestVehicles();
			break;

			case "showOrgChest":
				requestOrgChest();
				$(".use").css("display","none")
				$(".send").css("display","none")
				$(".inventory").css("display","flex")
				$(".myInfos2").html("");
				$(".amount").val(0);
			break;

			case "updateOrgChest":
				requestOrgChest();
			break;

			case "showChestHouse":
				requestHouseChest();
				$(".use").css("display","none")
				$(".send").css("display","none")
				$(".inventory").css("display","flex")
				$(".myInfos2").html("");
				$(".amount").val(0);
			break;

			case "updateChestHouse":
				requestHouseChest();
			break;

			case "showStore":
				requestStore();
				$(".use").css("display","none")
				$(".send").css("display","none")
				$(".inventory").css("display","flex")
				$(".myInfos2").html("");
				$(".amount").val(0);
			break;

			case "updateStore":
				requestStore();
			break;

			case "showRevistar":
				requestRevistar();
				$(".use").css("display","none")
				$(".send").css("display","none")
				$(".inventory").css("display","flex")
				$(".myInfos2").html("");
				$(".amount").val(0);
			break;

			case "updateRevistar":
				requestRevistar();
			break;
		}
	});

	document.onkeydown = data => {
		const key = data.key;
		if (key === "Shift") {
			shiftPressed = true;
		}
	}
	
	document.onkeyup = data => {
		const key = data.key;
		if (key === "Escape") {
			$.post("http://mirtin_inventory/invClose");
		} else if (key === "Shift") {
			shiftPressed = false;
		}
	};

	$('body').mousedown(e => {
		if (e.button == 1) return false;
	});

	$('.close').click(function() {
		$.post("http://mirtin_inventory/invClose", JSON.stringify({}));
	});
});

/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* SISTEMA DO INVENTARIO JOGADOR */
/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
let weightLeft = 0;
let maxWeightLeft = 0;

const updateMochila = () => {
	$.post("http://mirtin_inventory/requestMochila", JSON.stringify({}), (data) => {

		$(".myInfos").html(`
			<b>${data.infos[0]} <i>#${data.infos[1]}</i></b>
			<div class="infosContent">
				<span><s>TEL:</s> ${data.infos[2]}</span>
				<span><s>RG:</s> ${data.infos[3]}</span>
				<span><s>ORGANIZACAO:</s> ${data.infos[4]}</span>
				<span><s>PESO:</s> ${(data.peso).toFixed(2)} / ${(data.maxpeso).toFixed(2)}</span>
			</div>
		`);

		$(".invLeft").html("");
		$(".invRight").html("");

		const nameList2 = data.drop.sort((a, b) => (a.name > b.name) ? 1 : -1);
		for (let x = 1; x <= mySlots; x++) {
			const slot = x.toString();

			if (data.inventario[slot] !== undefined) {
				const v = data.inventario[slot];
				const item = `<div class="item populated" style="background-image: url('http://177.54.148.235:1010/inventario/${v.key}.png'); background-position: center; background-repeat: no-repeat;" data-item-key="${v.key}" data-name-key="${v.name}" data-amount="${v.amount}" data-slot="${slot}">
					<div class="top">
					<div class="itemWeight">${(v.peso*v.amount).toFixed(2)}</div>
					<div class="itemAmount">${formatarNumero(v.amount)}x</div>
					</div>
					<div class="itemname">${v.name}</div>
				</div>`;
				$(".invLeft").append(item);
			} else {
				const item = `<div class="item empty" data-slot="${slot}"></div>`;
				$(".invLeft").append(item);
			}
		}
		
		for (let x = 1; x <= inSlots; x++) {
			const slot = x.toString();
			if (nameList2[x - 1] !== undefined) {
				const v = nameList2[x - 1];
				
				const item = `<div class="item populated" style="background-image: url('http://177.54.148.235:1010/inventario/${v.key}.png'); background-position: center; background-repeat: no-repeat;" data-item-key="${v.key}" data-name-key="${v.name}" data-id="${v.id}" data-grid="${v.grid}" data-amount="${v.amount}" data-peso="${v.peso}" data-slot="${slot}">
				<div class="top">
				<div class="itemWeight">${(v.peso*v.amount).toFixed(2)}</div>
				<div class="itemAmount">${formatarNumero(v.amount)}x</div>
				</div>
				<div class="itemname">${v.name}</div>
			</div>`;

				$(".invRight").append(item);
			} else {
				const item = `<div class="item empty" data-slot="${slot}"></div>`;

				$(".invRight").append(item);
			}
		}

		updateDrag();
	});
}

const updateDrag = () => {
	$('.populated').draggable({
		helper: 'clone'
	});

	$('.empty').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			if (ui.draggable.parent()[0] == undefined) return;

			const origin = ui.draggable.parent()[0].className;
			if (origin === undefined) return;
			const tInv = $(this).parent()[0].className;

			if (origin === "invRight" && tInv === "invRight") return;

			itemData = { key: ui.draggable.data('item-key'), slot: ui.draggable.data('slot') };
			const targetname = $(this).data('item-key');
			const target = $(this).data('slot');

			if (itemData.key === undefined || target === undefined) return;

			let amount = 0;
			let itemAmount = parseInt(ui.draggable.data('amount'));
			if (parseInt($(".amount").val()) < 0 | $(".amount").val() == "" | parseInt($(".amount").val()) == 0 | shiftPressed | parseInt($(".amount").val()) > itemAmount | (itemData.key == "money" && origin === "invLeft" && tInv === "invLeft") ) {
				amount = itemAmount;
			}else{
				amount = parseInt($(".amount").val());
			}

			$('.populated, .empty, .use').off("draggable droppable");
			$('.populated, .empty, .send').off("draggable droppable");

			let clone1 = ui.draggable.clone();
			let slot2 = $(this).data("slot");

			if (amount == itemAmount) {
				let clone2 = $(this).clone();
				let slot1 = ui.draggable.data("slot");

				$(this).replaceWith(clone1);
				ui.draggable.replaceWith(clone2);

				$(clone1).data("slot", slot2);
				$(clone2).data("slot", slot1);
			} else {
				let newAmountOldItem = itemAmount - amount;
				let weight = parseFloat(ui.draggable.children(".top").children(".itemWeight").html());
				let weightPerItem = (weight / itemAmount).toFixed(2);
				let newWeightClone1 = (amount * weightPerItem).toFixed(2);
				let newWeightOldItem = (newAmountOldItem * weightPerItem).toFixed(2);

				ui.draggable.data("amount", newAmountOldItem);

				clone1.data("amount", amount);

				$(this).replaceWith(clone1);
				$(clone1).data("slot", slot2);

				ui.draggable.children(".top").children(".itemAmount").html(ui.draggable.data("amount") + "x");
				ui.draggable.children(".top").children(".itemWeight").html(newWeightOldItem);

				$(clone1).children(".top").children(".itemAmount").html(clone1.data("amount") + "x");
				$(clone1).children(".top").children(".itemWeight").html(newWeightClone1);
			}

			let futureWeightLeft = weightLeft;

			if (origin === "invLeft" && tInv === "invRight") {
				futureWeightLeft = futureWeightLeft - (parseFloat(ui.draggable.data('peso')) * amount);
			} else if (origin === "invRight" && tInv === "invLeft") {
				futureWeightLeft = futureWeightLeft + (parseFloat(ui.draggable.data('peso')) * amount);
			}

			weightLeft = futureWeightLeft;
			

			if (origin === "invLeft" && tInv === "invLeft") {	
				$.post("http://mirtin_inventory/updateSlot", JSON.stringify({
					item: itemData.key,
					slot: itemData.slot,
					amount: parseInt(amount),
					target: target
				}));
			} else if (origin === "invRight" && tInv === "invLeft") {
				const id = ui.draggable.data("id");
				const grid = ui.draggable.data("grid");
				$.post("http://mirtin_inventory/pickupItem", JSON.stringify({
					id: id,
					grid: grid,
					target: target,
					amount: parseInt(amount)
				}));
			} else if (origin === "invLeft" && tInv === "invRight") {
				$.post("http://mirtin_inventory/dropItem", JSON.stringify({
					item: itemData.key,
					slot: itemData.slot,
					amount: parseInt(amount)
				}));
			}

			updateDrag();
			updateMochila();
		}
	});

	$('.populated').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			if (ui.draggable.parent()[0] == undefined) return;

			const origin = ui.draggable.parent()[0].className;
			if (origin === undefined) return;
			const tInv = $(this).parent()[0].className;

			if (origin === "invRight" && tInv === "invRight") return;

			itemData = { key: ui.draggable.data('item-key'), slot: ui.draggable.data('slot') };
			const target = $(this).data('slot');
			const targetname = $(this).data('item-key');
			const targetamount = $(this).data('amount');

			if (itemData.key === undefined || target === undefined) return;

			let amount = 0;
			let itemAmount = parseInt(ui.draggable.data('amount'));
			if ($(".amount").val() == "" | parseInt($(".amount").val()) == 0 | itemData.key != targetname | shiftPressed) {
				amount = itemAmount;
			}else{
				amount = parseInt($(".amount").val());
			}

			if (amount > itemAmount) {
				amount = itemAmount;
			}
			
			
			$('.populated, .empty, .use').off("draggable droppable");
			$('.populated, .empty, .send').off("draggable droppable");

			let futureWeightLeft = weightLeft;

			if (ui.draggable.data('item-key') == $(this).data('item-key')) {
				let newSlotAmount = amount + parseInt($(this).data('amount'));
				let newSlotWeight = parseFloat(ui.draggable.children(".top").children(".itemWeight").html()) + parseFloat($(this).children(".top").children(".itemWeight").html());

				$(this).data('amount', newSlotAmount);
				$(this).children(".top").children(".itemAmount").html(newSlotAmount + "x");
				$(this).children(".top").children(".itemWeight").html(newSlotWeight.toFixed(2));

				if (amount == itemAmount) {
					ui.draggable.replaceWith(`<div class="item empty" data-slot="${ui.draggable.data('slot')}"></div>`);
				} else {
					let newMovedAmount = itemAmount - amount;
					let newMovedWeight = newMovedAmount * parseFloat(ui.draggable.data("peso"));

					ui.draggable.data('amount', newMovedAmount);
					ui.draggable.children(".top").children(".itemAmount").html(newMovedAmount + "x");
					ui.draggable.children(".top").children(".itemWeight").html(newMovedWeight.toFixed(2));
				}

				if (origin === "invLeft" && tInv === "invRight") {
					futureWeightLeft = futureWeightLeft - (parseFloat(ui.draggable.data('peso')) * amount);
				} else if (origin === "invRight" && tInv === "invLeft") {
					futureWeightLeft = futureWeightLeft + (parseFloat(ui.draggable.data('peso')) * amount);
				}
			} else {
				if (origin === "invRight" && tInv === "invLeft") return;

				let clone1 = ui.draggable.clone();
				let clone2 = $(this).clone();

				let slot1 = ui.draggable.data("slot");
				let slot2 = $(this).data("slot");

				if (origin === "invLeft" && tInv === "invRight") {
					futureWeightLeft = futureWeightLeft - parseFloat(ui.draggable.data('amount')) + parseFloat($(this).data('amount'));
				}

				ui.draggable.replaceWith(clone2);
				$(this).replaceWith(clone1);

				$(clone1).data("slot", slot2);
				$(clone2).data("slot", slot1);
			}
			
			if (origin === "invLeft" && tInv === "invLeft") {
				$.post("http://mirtin_inventory/updateSlot", JSON.stringify({
					item: itemData.key,
					slot: itemData.slot,
					amount: parseInt(amount),
					target: target,
					targetname: targetname,
					targetamount: parseInt(targetamount)
				}));
			}
			
			updateDrag();
			updateMochila();
		}
	});

	$('.use').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			const origin = ui.draggable.parent()[0].className;
			if (origin === undefined || origin === "invRight") return;
			itemData = { key: ui.draggable.data('item-key'), slot: ui.draggable.data('slot') };

			if (itemData.key === undefined) return;

			$.post("http://mirtin_inventory/useItem", JSON.stringify({
				item: itemData.key,
				slot: itemData.slot,
				amount: parseInt(parseInt($(".amount").val()))
			}));
		}
	});

	$('.send').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			const origin = ui.draggable.parent()[0].className;
			if (origin === undefined || origin === "invRight") return;
			itemData = { key: ui.draggable.data('item-key'), slot: ui.draggable.data('slot') };

			if (itemData.key === undefined) return;

			let amount = 0;
			let itemAmount = parseInt(ui.draggable.data('amount'));
			if (parseInt($(".amount").val()) < 0 | $(".amount").val() == "" | parseInt($(".amount").val()) == 0 | shiftPressed | parseInt($(".amount").val()) > itemAmount ) {
				amount = itemAmount;
			}else{
				amount = parseInt($(".amount").val());
			}

			$.post("http://mirtin_inventory/sendItem", JSON.stringify({
				item: itemData.key,
				slot: itemData.slot,
				amount: amount
			}));
		}
	});

	$(".populated").on("auxclick", e => {
		e.preventDefault();
		if (e.which === 3) {
			const item = e.target;
			const origin = $(item).parent()[0].className;
			if (origin === undefined || origin === "invRight") return;

			itemData = { key: $(item).data('item-key'), slot: $(item).data('slot') };

			if (itemData.key === undefined) return;

			$.post("http://mirtin_inventory/useItem", JSON.stringify({
				item: itemData.key,
				slot: itemData.slot,
				amount: parseInt(parseInt($(".amount").val()))
			}));
		}
	});
}

/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* SISTEMA DE INVENTARIO VEICULOS */
/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
const requestVehicles = () => {
	$.post("http://mirtin_inventory/requestVehicle",JSON.stringify({}),(data) => {
		$(".myInfos").html(`
			<b>${data.infos[0]} <i>#${data.infos[1]}</i></b>
			<div class="infosContent">
				<span><s>PESO: </s>${(data.peso).toFixed(2)} / ${(data.maxpeso).toFixed(2)}</span>
			</div>
		`);

		$(".myInfos2").html(`
			<div class="myInfos">
				<b>${data.infosVehicle[1]} <i style="font-size: 16px;">${data.infosVehicle[0]}</i></b>
				<div class="infosContent">
					<span><s>PESO: </s>${(data.peso2).toFixed(2)} / ${(data.maxpeso2).toFixed(2)}</span>
				</div>
			</div>
		`);

		vehicleWeightLeft = data.peso2;
		vehicleMaxWeightLeft = data.maxpeso2;

		$(".invLeft").html("");
		$(".invRight").html("");
		for (let x=1; x <= mySlots; x++) {
			const slot = x.toString();

			if (data.inventario[slot] !== undefined) {
				const v = data.inventario[slot];
				const item = `<div class="item populated" style="background-image: url('http://177.54.148.235:1010/inventario/${v.key}.png'); background-position: center; background-repeat: no-repeat;" data-item-key="${v.key}" data-name-key="${v.name}" data-amount="${v.amount}" data-slot="${slot}">
					<div class="top">
						<div class="itemWeight">${(v.peso*v.amount).toFixed(2)}</div>
						<div class="itemAmount">${formatarNumero(v.amount)}x</div>
					</div>
					<div class="itemname">${v.name}</div>
				</div>`;

				$(".invLeft").append(item);
			} else {
				const item = `<div class="item empty" data-slot="${slot}"></div>`;

				$(".invLeft").append(item);
			}
		}


		for (let x=1; x <= inSlots; x++) {
			const slot = x.toString();
			if (data.inventario2[slot] !== undefined) {
				const v = data.inventario2[slot];
				const item = `<div class="item populated" style="background-image: url('http://177.54.148.235:1010/inventario/${v.key}.png'); background-position: center; background-repeat: no-repeat;" data-item-key="${v.key}" data-name-key="${v.name}" data-amount="${v.amount}" data-slot="${slot}">
					<div class="top">
						<div class="itemWeight">${(v.peso*v.amount).toFixed(2)}</div>
						<div class="itemAmount">${formatarNumero(v.amount)}x</div>
					</div>
					<div class="itemname">${v.name}</div>
				</div>`;

				$(".invRight").append(item);
			} else {
				const item = `<div class="item empty" data-slot="${slot}"></div>`;

				$(".invRight").append(item);
			}
		}

		updateDragVehicles();
	});
}

const updateDragVehicles = () => {
	$('.populated').draggable({
		helper: 'clone'
	});

	$('.empty').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			const origin = ui.draggable.parent()[0].className;
			if (origin === undefined) return;
			const tInv = $(this).parent()[0].className;

			itemData = { key: ui.draggable.data('item-key'), slot: ui.draggable.data('slot') };
			const target = $(this).data('slot');

			if (itemData.key === undefined || target === undefined) return;

			let amount = 0;
			let itemAmount = parseInt(ui.draggable.data('amount'));
			if (parseInt($(".amount").val()) < 0 | $(".amount").val() == "" | parseInt($(".amount").val()) == 0 | shiftPressed | parseInt($(".amount").val()) > itemAmount | (itemData.key == "money" && origin === "invLeft" && tInv === "invLeft")) {
				amount = itemAmount;
			}else{
				amount = parseInt($(".amount").val());
			}

			if (tInv === "invLeft") {
				if (origin === "invLeft") {
					$.post("http://mirtin_inventory/updateSlot", JSON.stringify({
						item: itemData.key,
						slot: itemData.slot,
						target: target,
						amount: amount
					}))
				} else if (origin === "invRight") {
					$.post("http://mirtin_inventory/takeVehicle", JSON.stringify({
						item: itemData.key,
						slot: itemData.slot,
						target: target,
						amount: amount
					}));
				}

			} else if (tInv === "invRight") {
				if (origin === "invRight") {
					$.post("http://mirtin_inventory/updateVehicleSlots", JSON.stringify({
						item: itemData.key,
						slot: itemData.slot,
						target: target,
						amount: amount
					}))
				}else if (origin === "invLeft") {
					$.post("http://mirtin_inventory/storeVehicle", JSON.stringify({
						item: itemData.key,
						slot: target,
						amount: amount
					}));
				}
			}

			requestVehicles()
			updateDragVehicles()
		}
	});

	
	$('.populated').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			if (ui.draggable.parent()[0] == undefined) return;
			
			const origin = ui.draggable.parent()[0].className;

			
			if (origin === undefined) return;
			const tInv = $(this).parent()[0].className;

			itemData = { key: ui.draggable.data('item-key'), slot: ui.draggable.data('slot') };
			const target = $(this).data('slot');
			const targetname = $(this).data('item-key');
			const targetamount = $(this).data('amount');

			if (itemData.key === undefined || target === undefined) return;

			let amount = 0;
			let itemAmount = parseInt(ui.draggable.data('amount'));
			if ($(".amount").val() == "" | parseInt($(".amount").val()) == 0 | itemData.key != targetname | shiftPressed) {
				amount = itemAmount;
			}else{
				amount = parseInt($(".amount").val());
			}

			if (amount > itemAmount) {
				amount = itemAmount;
			}

			let futureWeightLeft = weightLeft;

			if (ui.draggable.data('item-key') == $(this).data('item-key')) {
				let newSlotAmount = amount + parseInt($(this).data('amount'));
				let newSlotWeight = parseFloat(ui.draggable.children(".top").children(".itemWeight").html()) + parseFloat($(this).children(".top").children(".itemWeight").html());

				$(this).data('amount', newSlotAmount);
				$(this).children(".top").children(".itemAmount").html(newSlotAmount + "x");
				$(this).children(".top").children(".itemWeight").html(newSlotWeight.toFixed(2));

				if (amount == itemAmount) {
					ui.draggable.replaceWith(`<div class="item empty" data-slot="${ui.draggable.data('slot')}"></div>`);
				} else {
					let newMovedAmount = itemAmount - amount;
					let newMovedWeight = newMovedAmount * parseFloat(ui.draggable.data("peso"));

					ui.draggable.data('amount', newMovedAmount);
					ui.draggable.children(".top").children(".itemAmount").html(newMovedAmount + "x");
					ui.draggable.children(".top").children(".itemWeight").html(newMovedWeight.toFixed(2));
				}

				if (origin === "invLeft" && tInv === "invRight") {
					futureWeightLeft = futureWeightLeft - (parseFloat(ui.draggable.data('peso')) * amount);
				} else if (origin === "invRight" && tInv === "invLeft") {
					futureWeightLeft = futureWeightLeft + (parseFloat(ui.draggable.data('peso')) * amount);
				}
			} else {
				if (origin === "invRight" && tInv === "invLeft") return;

				let clone1 = ui.draggable.clone();
				let clone2 = $(this).clone();

				let slot1 = ui.draggable.data("slot");
				let slot2 = $(this).data("slot");

				if (origin === "invLeft" && tInv === "invRight") {
					futureWeightLeft = futureWeightLeft - parseFloat(ui.draggable.data('amount')) + parseFloat($(this).data('amount'));
				}

				ui.draggable.replaceWith(clone2);
				$(this).replaceWith(clone1);

				$(clone1).data("slot", slot2);
				$(clone2).data("slot", slot1);
			}

			

			if (origin === "invLeft" && tInv === "invLeft") {
				$.post("http://mirtin_inventory/updateSlot", JSON.stringify({
					item: itemData.key,
					slot: itemData.slot,
					amount: parseInt(amount),
					target: target,
					targetname: targetname,
					targetamount: parseInt(targetamount)
				}));
			}else if (origin === "invRight" && tInv === "invRight") {
				$.post("http://mirtin_inventory/updateVehicleSlots", JSON.stringify({
					item: itemData.key,
					slot: itemData.slot,
					amount: parseInt(amount),
					target: target,
					targetname: targetname,
					targetamount: parseInt(targetamount)
				}));
			}
			
			requestVehicles()
			updateDragVehicles()
		}
	});
	
}

/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* SISTEMA DE INVENTARIO DA ORGANIZACAO */
/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
const requestOrgChest = () => {
	$.post("http://mirtin_inventory/requestOrgChest",JSON.stringify({}),(data) => {
		$(".myInfos").html(`
			<b>${data.infos[0]} <i>#${data.infos[1]}</i></b>
			<div class="infosContent">
				<span><s>PESO: </s>${(data.peso).toFixed(2)} / ${(data.maxpeso).toFixed(2)}</span>
			</div>
		`);

		$(".myInfos2").html(`
			<div class="myInfos">
				<b>${data.infosOrg[1]} <i>#${data.infosOrg[0]}</i></b>
				<div class="infosContent">
					<span><s>PESO: </s>${(data.peso2).toFixed(2)} / ${(data.maxpeso2).toFixed(2)}</span>
				</div>
			</div>
		`);

		$(".invLeft").html("");
		$(".invRight").html("");
		for (let x=1; x <= mySlots; x++) {
			const slot = x.toString();

			if (data.inventario[slot] !== undefined) {
				const v = data.inventario[slot];
				const item = `<div class="item populated" style="background-image: url('http://177.54.148.235:1010/inventario/${v.key}.png'); background-position: center; background-repeat: no-repeat;" data-item-key="${v.key}" data-name-key="${v.name}" data-amount="${v.amount}" data-slot="${slot}">
					<div class="top">
						<div class="itemWeight">${(v.peso*v.amount).toFixed(2)}</div>
						<div class="itemAmount">${formatarNumero(v.amount)}x</div>
					</div>
					<div class="itemname">${v.name}</div>
				</div>`;

				$(".invLeft").append(item);
			} else {
				const item = `<div class="item empty" data-slot="${slot}"></div>`;

				$(".invLeft").append(item);
			}
		}


		for (let x=1; x <= inSlots; x++) {
			const slot = x.toString();
			if (data.inventario2[slot] !== undefined) {
				const v = data.inventario2[slot];
				const item = `<div class="item populated" style="background-image: url('http://177.54.148.235:1010/inventario/${v.key}.png'); background-position: center; background-repeat: no-repeat;" data-item-key="${v.key}" data-name-key="${v.name}" data-amount="${v.amount}" data-slot="${slot}">
					<div class="top">
						<div class="itemWeight">${(v.peso*v.amount).toFixed(2)}</div>
						<div class="itemAmount">${formatarNumero(v.amount)}x</div>
					</div>
					<div class="itemname">${v.name}</div>
				</div>`;

				$(".invRight").append(item);
			} else {
				const item = `<div class="item empty" data-slot="${slot}"></div>`;

				$(".invRight").append(item);
			}
		}

		updateDragOrgChest();
	});
}

const updateDragOrgChest = () => {
	$('.populated').draggable({
		helper: 'clone'
	});

	$('.empty').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			const origin = ui.draggable.parent()[0].className;
			if (origin === undefined) return;
			const tInv = $(this).parent()[0].className;

			itemData = { key: ui.draggable.data('item-key'), slot: ui.draggable.data('slot') };
			const target = $(this).data('slot');

			if (itemData.key === undefined || target === undefined) return;

			let amount = 0;
			let itemAmount = parseInt(ui.draggable.data('amount'));
			if (parseInt($(".amount").val()) < 0 | $(".amount").val() == "" | parseInt($(".amount").val()) == 0 | shiftPressed | parseInt($(".amount").val()) > itemAmount | (itemData.key == "money" && origin === "invLeft" && tInv === "invLeft")) {
				amount = itemAmount;
			}else{
				amount = parseInt($(".amount").val());
			}


			if (tInv === "invLeft") {
				if (origin === "invLeft") {
					$.post("http://mirtin_inventory/updateSlot", JSON.stringify({
						item: itemData.key,
						slot: itemData.slot,
						target: target,
						amount: amount
					}))
				} else if (origin === "invRight") {
					$.post("http://mirtin_inventory/takeOrgChest", JSON.stringify({
						item: itemData.key,
						slot: itemData.slot,
						target: target,
						amount: amount
					}));
				}

			} else if (tInv === "invRight") {
				if (origin === "invRight") {
					$.post("http://mirtin_inventory/updateOrgSlots", JSON.stringify({
						item: itemData.key,
						slot: itemData.slot,
						target: target,
						amount: amount
					}))
				}else if (origin === "invLeft") {
					$.post("http://mirtin_inventory/storeOrgChest", JSON.stringify({
						item: itemData.key,
						slot: target,
						amount: amount
					}));
				}
			}

			requestOrgChest()
			updateDragOrgChest()
		}
	});

	
	$('.populated').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			if (ui.draggable.parent()[0] == undefined) return;
			
			const origin = ui.draggable.parent()[0].className;

			
			if (origin === undefined) return;
			const tInv = $(this).parent()[0].className;

			itemData = { key: ui.draggable.data('item-key'), slot: ui.draggable.data('slot') };
			const target = $(this).data('slot');
			const targetname = $(this).data('item-key');
			const targetamount = $(this).data('amount');

			if (itemData.key === undefined || target === undefined) return;

			let amount = 0;
			let itemAmount = parseInt(ui.draggable.data('amount'));
			if ($(".amount").val() == "" | parseInt($(".amount").val()) == 0 | itemData.key != targetname | shiftPressed) {
				amount = itemAmount;
			}else{
				amount = parseInt($(".amount").val());
			}

			if (amount > itemAmount) {
				amount = itemAmount;
			}
			
			let futureWeightLeft = weightLeft;
				

			if (ui.draggable.data('item-key') == $(this).data('item-key')) {
				let newSlotAmount = amount + parseInt($(this).data('amount'));
				let newSlotWeight = parseFloat(ui.draggable.children(".top").children(".itemWeight").html()) + parseFloat($(this).children(".top").children(".itemWeight").html());

				$(this).data('amount', newSlotAmount);
				$(this).children(".top").children(".itemAmount").html(newSlotAmount + "x");
				$(this).children(".top").children(".itemWeight").html(newSlotWeight.toFixed(2));

				if (amount == itemAmount) {
					ui.draggable.replaceWith(`<div class="item empty" data-slot="${ui.draggable.data('slot')}"></div>`);
				} else {
					let newMovedAmount = itemAmount - amount;
					let newMovedWeight = newMovedAmount * parseFloat(ui.draggable.data("peso"));

					ui.draggable.data('amount', newMovedAmount);
					ui.draggable.children(".top").children(".itemAmount").html(newMovedAmount + "x");
					ui.draggable.children(".top").children(".itemWeight").html(newMovedWeight.toFixed(2));
				}

				if (origin === "invLeft" && tInv === "invRight") {
					futureWeightLeft = futureWeightLeft - (parseFloat(ui.draggable.data('peso')) * amount);
				} else if (origin === "invRight" && tInv === "invLeft") {
					futureWeightLeft = futureWeightLeft + (parseFloat(ui.draggable.data('peso')) * amount);
				}
			} else {
				if (origin === "invRight" && tInv === "invLeft") return;

				let clone1 = ui.draggable.clone();
				let clone2 = $(this).clone();

				let slot1 = ui.draggable.data("slot");
				let slot2 = $(this).data("slot");

				if (origin === "invLeft" && tInv === "invRight") {
					futureWeightLeft = futureWeightLeft - parseFloat(ui.draggable.data('amount')) + parseFloat($(this).data('amount'));
				}

				ui.draggable.replaceWith(clone2);
				$(this).replaceWith(clone1);

				$(clone1).data("slot", slot2);
				$(clone2).data("slot", slot1);
			}

			

			if (origin === "invLeft" && tInv === "invLeft") {
				$.post("http://mirtin_inventory/updateSlot", JSON.stringify({
					item: itemData.key,
					slot: itemData.slot,
					amount: parseInt(amount),
					target: target,
					targetname: targetname,
					targetamount: parseInt(targetamount)
				}));
			}else if (origin === "invRight" && tInv === "invRight") {
				$.post("http://mirtin_inventory/updateOrgSlots", JSON.stringify({
					item: itemData.key,
					slot: itemData.slot,
					amount: parseInt(amount),
					target: target,
					targetname: targetname,
					targetamount: parseInt(targetamount)
				}));
			}
			
			requestOrgChest()
			updateDragOrgChest()
		}
	});
	
}

/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* SISTEMA DE INVENTARIO DO BAU DA CASA */
/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
const requestHouseChest = () => {
	$.post("http://mirtin_inventory/requestHouseChest",JSON.stringify({}),(data) => {
		$(".myInfos").html(`
			<b> ${data.infos[0]} <i>#${data.infos[1]}</i></b>
			<div class="infosContent">
				<span><s>PESO: </s>${(data.peso).toFixed(2)} / ${(data.maxpeso).toFixed(2)}</span>
			</div>
		`);

		$(".myInfos2").html(`
			<div class="myInfos">
				<b>House <i>#${data.infosOrg[0]}</i></b>
				<div class="infosContent">
					<span><s>PESO: </s>${(data.peso2).toFixed(2)} / ${(data.maxpeso2).toFixed(2)}</span>
				</div>
			</div>
		`);

		$(".invLeft").html("");
		$(".invRight").html("");
		for (let x=1; x <= mySlots; x++) {
			const slot = x.toString();

			if (data.inventario[slot] !== undefined) {
				const v = data.inventario[slot];
				const item = `<div class="item populated" style="background-image: url('http://177.54.148.235:1010/inventario/${v.key}.png'); background-position: center; background-repeat: no-repeat;" data-item-key="${v.key}" data-name-key="${v.name}" data-amount="${v.amount}" data-slot="${slot}">
					<div class="top">
						<div class="itemWeight">${(v.peso*v.amount).toFixed(2)}</div>
						<div class="itemAmount">${formatarNumero(v.amount)}x</div>
					</div>
					<div class="itemname">${v.name}</div>
				</div>`;

				$(".invLeft").append(item);
			} else {
				const item = `<div class="item empty" data-slot="${slot}"></div>`;

				$(".invLeft").append(item);
			}
		}


		for (let x=1; x <= inSlots; x++) {
			const slot = x.toString();
			if (data.inventario2[slot] !== undefined) {
				const v = data.inventario2[slot];
				const item = `<div class="item populated" style="background-image: url('http://177.54.148.235:1010/inventario/${v.key}.png'); background-position: center; background-repeat: no-repeat;" data-item-key="${v.key}" data-name-key="${v.name}" data-amount="${v.amount}" data-slot="${slot}">
					<div class="top">
						<div class="itemWeight">${(v.peso*v.amount).toFixed(2)}</div>
						<div class="itemAmount">${formatarNumero(v.amount)}x</div>
					</div>
					<div class="itemname">${v.name}</div>
				</div>`;

				$(".invRight").append(item);
			} else {
				const item = `<div class="item empty" data-slot="${slot}"></div>`;

				$(".invRight").append(item);
			}
		}

		updateHouseChest();
	});
}

const updateHouseChest = () => {
	$('.populated').draggable({
		helper: 'clone'
	});

	$('.empty').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			const origin = ui.draggable.parent()[0].className;
			if (origin === undefined) return;
			const tInv = $(this).parent()[0].className;

			itemData = { key: ui.draggable.data('item-key'), slot: ui.draggable.data('slot') };
			const target = $(this).data('slot');

			if (itemData.key === undefined || target === undefined) return;

			let amount = 0;
			let itemAmount = parseInt(ui.draggable.data('amount'));
			if (parseInt($(".amount").val()) < 0 | $(".amount").val() == "" | parseInt($(".amount").val()) == 0 | shiftPressed | parseInt($(".amount").val()) > itemAmount |  (itemData.key == "money" && origin === "invLeft" && tInv === "invLeft")) {
				amount = itemAmount;
			}else{
				amount = parseInt($(".amount").val());
			}

			if (tInv === "invLeft") {
				if (origin === "invLeft") {
					$.post("http://mirtin_inventory/updateSlot", JSON.stringify({
						item: itemData.key,
						slot: itemData.slot,
						target: target,
						amount: amount
					}))
				} else if (origin === "invRight") {
					$.post("http://mirtin_inventory/takeHouseChest", JSON.stringify({
						item: itemData.key,
						slot: itemData.slot,
						target: target,
						amount: amount
					}));
				}

			} else if (tInv === "invRight") {
				if (origin === "invRight") {
					$.post("http://mirtin_inventory/updateChestSlots", JSON.stringify({
						item: itemData.key,
						slot: itemData.slot,
						target: target,
						amount: amount
					}))
				}else if (origin === "invLeft") {
					$.post("http://mirtin_inventory/storeHouseChest", JSON.stringify({
						item: itemData.key,
						slot: target,
						amount: amount
					}));
				}
			}

			updateHouseChest()
			requestHouseChest()
		}
	});

	
	$('.populated').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			if (ui.draggable.parent()[0] == undefined) return;
			
			const origin = ui.draggable.parent()[0].className;

			
			if (origin === undefined) return;
			const tInv = $(this).parent()[0].className;

			itemData = { key: ui.draggable.data('item-key'), slot: ui.draggable.data('slot') };
			const target = $(this).data('slot');
			const targetname = $(this).data('item-key');
			const targetamount = $(this).data('amount');

			if (itemData.key === undefined || target === undefined) return;

			let amount = 0;
			let itemAmount = parseInt(ui.draggable.data('amount'));
			if ($(".amount").val() == "" | parseInt($(".amount").val()) == 0 | itemData.key != targetname | shiftPressed) {
				amount = itemAmount;
			}else{
				amount = parseInt($(".amount").val());
			}

			if (amount > itemAmount) {
				amount = itemAmount;
			}
			
			let futureWeightLeft = weightLeft;

			if (ui.draggable.data('item-key') == $(this).data('item-key')) {
				let newSlotAmount = amount + parseInt($(this).data('amount'));
				let newSlotWeight = parseFloat(ui.draggable.children(".top").children(".itemWeight").html()) + parseFloat($(this).children(".top").children(".itemWeight").html());

				$(this).data('amount', newSlotAmount);
				$(this).children(".top").children(".itemAmount").html(newSlotAmount + "x");
				$(this).children(".top").children(".itemWeight").html(newSlotWeight.toFixed(2));

				if (amount == itemAmount) {
					ui.draggable.replaceWith(`<div class="item empty" data-slot="${ui.draggable.data('slot')}"></div>`);
				} else {
					let newMovedAmount = itemAmount - amount;
					let newMovedWeight = newMovedAmount * parseFloat(ui.draggable.data("peso"));

					ui.draggable.data('amount', newMovedAmount);
					ui.draggable.children(".top").children(".itemAmount").html(newMovedAmount + "x");
					ui.draggable.children(".top").children(".itemWeight").html(newMovedWeight.toFixed(2));
				}

				if (origin === "invLeft" && tInv === "invRight") {
					futureWeightLeft = futureWeightLeft - (parseFloat(ui.draggable.data('peso')) * amount);
				} else if (origin === "invRight" && tInv === "invLeft") {
					futureWeightLeft = futureWeightLeft + (parseFloat(ui.draggable.data('peso')) * amount);
				}
			} else {
				if (origin === "invRight" && tInv === "invLeft") return;

				let clone1 = ui.draggable.clone();
				let clone2 = $(this).clone();

				let slot1 = ui.draggable.data("slot");
				let slot2 = $(this).data("slot");

				if (origin === "invLeft" && tInv === "invRight") {
					futureWeightLeft = futureWeightLeft - parseFloat(ui.draggable.data('amount')) + parseFloat($(this).data('amount'));
				}

				ui.draggable.replaceWith(clone2);
				$(this).replaceWith(clone1);

				$(clone1).data("slot", slot2);
				$(clone2).data("slot", slot1);
			}

			

			if (origin === "invLeft" && tInv === "invLeft") {
				$.post("http://mirtin_inventory/updateSlot", JSON.stringify({
					item: itemData.key,
					slot: itemData.slot,
					amount: parseInt(amount),
					target: target,
					targetname: targetname,
					targetamount: parseInt(targetamount)
				}));
			}else if (origin === "invRight" && tInv === "invRight") {
				$.post("http://mirtin_inventory/updateChestSlots", JSON.stringify({
					item: itemData.key,
					slot: itemData.slot,
					amount: parseInt(amount),
					target: target,
					targetname: targetname,
					targetamount: parseInt(targetamount)
				}));
			}
			
			updateHouseChest()
			requestHouseChest()
		}
	});
	
}

/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* SISTEMA DE LOJA */
/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
const requestStore = () => {
	$.post("http://mirtin_inventory/requestStore",JSON.stringify({}),(data) => {
		$(".myInfos").html(`
			<b> ${data.infos[0]} <i>#${data.infos[1]}</i></b>
			<div class="infosContent">
				<span><s>PESO: </s>${(data.peso).toFixed(2)} / ${(data.maxpeso).toFixed(2)}</span>
			</div>
		`);

		$(".myInfos2").html(`
			<div class="myInfos">
				<b>Loja <i style="font-size: 16px;">${data.infosOrg[0]}</i></b>
				<div class="infosContent">
					<span>
						<b style="color: green; font-size: 10px;">B: </b> para comprar, caso fique sem estoque fica impossivel de comprar<br> 
						<b style="color: red; font-size: 10px;">S: </b> para vender, caso fique indisponivel fica impossivel de vender.
					</span>
				</div>
			</div>
		`);

		$(".invLeft").html("");
		$(".invRight").html("");
		for (let x=1; x <= mySlots; x++) {
			const slot = x.toString();

			if (data.inventario[slot] !== undefined) {
				const v = data.inventario[slot];
				const item = `<div class="item populated" style="background-image: url('http://177.54.148.235:1010/inventario/${v.key}.png'); background-position: center; background-repeat: no-repeat;" data-item-key="${v.key}" data-name-key="${v.name}" data-amount="${v.amount}" data-slot="${slot}">
					<div class="top">
						<div class="itemWeight">${(v.peso*v.amount).toFixed(2)}</div>
						<div class="itemAmount">${formatarNumero(v.amount)}x</div>
					</div>
					<div class="itemname">${v.name}</div>
				</div>`;

				$(".invLeft").append(item);
			} else {
				const item = `<div class="item empty" data-slot="${slot}"></div>`;

				$(".invLeft").append(item);
			}
		}


		for (let x=1; x <= inSlots; x++) {
			const slot = x.toString();
			if (data.inventario2[slot] !== undefined) {
				const v = data.inventario2[slot];
				if (v.buyPrice == 0) { v.buyPrice = "Free" } else if (v.buyPrice == undefined) { v.buyPrice = "Sem Estoque" } 		
				if (v.sellPrice == 0) { v.sellPrice = "Free" } else if (v.sellPrice == undefined) { v.sellPrice = "Indisponivel" } 

				const item = `<div class="item populated" style="background-image: url('http://177.54.148.235:1010/inventario/${v.key}.png'); background-position: center; background-repeat: no-repeat;" data-item-key="${v.key}" data-name-key="${v.name}" data-amount="${v.amount}" data-slot="${slot}">
					<div class="top">
						<div class="itemWeight"><b style="color: green;">B: </b>${v.buyPrice}<br><b style="color: red;">S:</b> ${v.sellPrice}</div>
					</div>
					<div class="itemname">${v.name}</div>
				</div>`;

				$(".invRight").append(item);
			} else {
				const item = `<div class="item empty" data-slot="${slot}"></div>`;

				$(".invRight").append(item);
			}
		}

		updateStore();
	});
}

const updateStore = () => {
	$('.populated').draggable({
		helper: 'clone'
	});

	$('.empty').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			const origin = ui.draggable.parent()[0].className;
			if (origin === undefined) return;
			const tInv = $(this).parent()[0].className;

			itemData = { key: ui.draggable.data('item-key'), slot: ui.draggable.data('slot') };
			const target = $(this).data('slot');

			if (itemData.key === undefined || target === undefined) return;

			let amount = 0;
			let itemAmount = parseInt(ui.draggable.data('amount'));
			if (parseInt($(".amount").val()) < 0 | $(".amount").val() == "" | parseInt($(".amount").val()) == 0 | shiftPressed | parseInt($(".amount").val()) > itemAmount | (itemData.key == "money" && origin === "invLeft" && tInv === "invLeft")) {
				amount = itemAmount;
			}else{
				amount = parseInt($(".amount").val());
			}

			let buyAmount = 0;
			if ($(".amount").val() == "" | parseInt($(".amount").val()) == 0) {
				buyAmount = 1
			}else{
				buyAmount = $(".amount").val()
			}

			if (tInv === "invLeft") {
				if (origin === "invLeft") {
					$.post("http://mirtin_inventory/updateSlot", JSON.stringify({
						item: itemData.key,
						slot: itemData.slot,
						target: target,
						amount: amount
					}))
				} else if (origin === "invRight") {
					$.post("http://mirtin_inventory/buyStore", JSON.stringify({
						item: itemData.key,
						target: target,
						amount: buyAmount
					}));
				}

			} else if (tInv === "invRight") {
				if (origin === "invLeft") {
					$.post("http://mirtin_inventory/sellStore", JSON.stringify({
						item: itemData.key,
						amount: parseInt(amount)
					}));
				}
			}

			updateStore()
			requestStore()
		}
	});

	
	$('.populated').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			if (ui.draggable.parent()[0] == undefined) return;
			
			const origin = ui.draggable.parent()[0].className;

			
			if (origin === undefined) return;
			const tInv = $(this).parent()[0].className;

			itemData = { key: ui.draggable.data('item-key'), slot: ui.draggable.data('slot') };
			const target = $(this).data('slot');
			const targetname = $(this).data('item-key');
			const targetamount = $(this).data('amount');

			if (itemData.key === undefined || target === undefined) return;

			let amount = 0;
			let itemAmount = parseInt(ui.draggable.data('amount'));
			if ($(".amount").val() == "" | parseInt($(".amount").val()) == 0 | shiftPressed) {
				amount = itemAmount;
			}else{
				amount = parseInt($(".amount").val());
			}

			if (amount > itemAmount) {
				amount = itemAmount;
			}
			
			let futureWeightLeft = weightLeft;

			if (ui.draggable.data('item-key') == $(this).data('item-key')) {
				let newSlotAmount = amount + parseInt($(this).data('amount'));
				let newSlotWeight = parseFloat(ui.draggable.children(".top").children(".itemWeight").html()) + parseFloat($(this).children(".top").children(".itemWeight").html());

				$(this).data('amount', newSlotAmount);
				$(this).children(".top").children(".itemAmount").html(newSlotAmount + "x");
				$(this).children(".top").children(".itemWeight").html(newSlotWeight.toFixed(2));

				if (amount == itemAmount) {
					ui.draggable.replaceWith(`<div class="item empty" data-slot="${ui.draggable.data('slot')}"></div>`);
				} else {
					let newMovedAmount = itemAmount - amount;
					let newMovedWeight = newMovedAmount * parseFloat(ui.draggable.data("peso"));

					ui.draggable.data('amount', newMovedAmount);
					ui.draggable.children(".top").children(".itemAmount").html(newMovedAmount + "x");
					ui.draggable.children(".top").children(".itemWeight").html(newMovedWeight.toFixed(2));
				}

				if (origin === "invLeft" && tInv === "invRight") {
					futureWeightLeft = futureWeightLeft - (parseFloat(ui.draggable.data('peso')) * amount);
				} else if (origin === "invRight" && tInv === "invLeft") {
					futureWeightLeft = futureWeightLeft + (parseFloat(ui.draggable.data('peso')) * amount);
				}
			} else {
				if (origin === "invRight" && tInv === "invLeft") return;

				let clone1 = ui.draggable.clone();
				let clone2 = $(this).clone();

				let slot1 = ui.draggable.data("slot");
				let slot2 = $(this).data("slot");

				if (origin === "invLeft" && tInv === "invRight") {
					futureWeightLeft = futureWeightLeft - parseFloat(ui.draggable.data('amount')) + parseFloat($(this).data('amount'));
				}

				ui.draggable.replaceWith(clone2);
				$(this).replaceWith(clone1);

				$(clone1).data("slot", slot2);
				$(clone2).data("slot", slot1);
			}

			

			if (origin === "invLeft" && tInv === "invLeft") {
				$.post("http://mirtin_inventory/updateSlot", JSON.stringify({
					item: itemData.key,
					slot: itemData.slot,
					amount: parseInt(amount),
					target: target,
					targetname: targetname,
					targetamount: parseInt(targetamount)
				}));
			}
			
			updateStore()
			requestStore()
		}
	});
	
}
/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* SISTEMA DE REVISTAR */
/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
const requestRevistar = () => {
	$.post("http://mirtin_inventory/requestRevistar",JSON.stringify({}),(data) => {
		$(".myInfos").html(`
			<b> ${data.infos[0]} <i>#${data.infos[1]}</i></b>
			<div class="infosContent">
				<span><s>PESO: </s>${(data.peso).toFixed(2)} / ${(data.maxpeso).toFixed(2)}</span>
			</div>
		`);

		$(".myInfos2").html(`
			<div class="myInfos">
				<b>${data.infoNPlayer[0]} ${data.infoNPlayer[1]} <i>#${data.infoNPlayer[2]}</i></b>
				<div class="infosContent">
					<span><s>PESO: </s>${(data.peso2).toFixed(2)} / ${(data.maxpeso2).toFixed(2)}</span>
				</div>
			</div>
		`);

		$(".invLeft").html("");
		$(".invRight").html("");
		for (let x=1; x <= mySlots; x++) {
			const slot = x.toString();

			if (data.inventario[slot] !== undefined) {
				const v = data.inventario[slot];
				const item = `<div class="item populated" style="background-image: url('http://177.54.148.235:1010/inventario/${v.key}.png'); background-position: center; background-repeat: no-repeat;" data-item-key="${v.key}" data-name-key="${v.name}" data-amount="${v.amount}" data-slot="${slot}">
					<div class="top">
						<div class="itemWeight">${(v.peso*v.amount).toFixed(2)}</div>
						<div class="itemAmount">${formatarNumero(v.amount)}x</div>
					</div>
					<div class="itemname">${v.name}</div>
				</div>`;

				$(".invLeft").append(item);
			} else {
				const item = `<div class="item empty" data-slot="${slot}"></div>`;

				$(".invLeft").append(item);
			}
		}


		for (let x=1; x <= inSlots; x++) {
			const slot = x.toString();
			if (data.inventario2[slot] !== undefined) {
				const v = data.inventario2[slot];
				const item = `<div class="item populated" style="background-image: url('http://177.54.148.235:1010/inventario/${v.key}.png'); background-position: center; background-repeat: no-repeat;" data-item-key="${v.key}" data-name-key="${v.name}" data-amount="${v.amount}" data-slot="${slot}">
					<div class="top">
						<div class="itemWeight">${(v.peso*v.amount).toFixed(2)}</div>
						<div class="itemAmount">${formatarNumero(v.amount)}x</div>
					</div>
					<div class="itemname">${v.name}</div>
				</div>`;

				$(".invRight").append(item);
			} else {
				const item = `<div class="item empty" data-slot="${slot}"></div>`;

				$(".invRight").append(item);
			}
		}

		updateRevistar();
	});
}

const updateRevistar = () => {
	$('.populated').draggable({
		helper: 'clone'
	});

	$('.empty').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			const origin = ui.draggable.parent()[0].className;
			if (origin === undefined) return;
			const tInv = $(this).parent()[0].className;

			itemData = { key: ui.draggable.data('item-key'), slot: ui.draggable.data('slot') };
			const target = $(this).data('slot');

			if (itemData.key === undefined || target === undefined) return;

			let amount = 0;
			let itemAmount = parseInt(ui.draggable.data('amount'));
			if (parseInt($(".amount").val()) < 0 | $(".amount").val() == "" | parseInt($(".amount").val()) == 0 | shiftPressed | parseInt($(".amount").val()) > itemAmount | (itemData.key == "money" && origin === "invLeft" && tInv === "invLeft")) {
				amount = itemAmount;
			}else{
				amount = parseInt($(".amount").val());
			}
			
			if (tInv === "invLeft") {
				if (origin === "invLeft") {
					$.post("http://mirtin_inventory/updateSlot", JSON.stringify({
						item: itemData.key,
						slot: itemData.slot,
						target: target,
						amount: amount
					}))
				} else if (origin === "invRight") {
					$.post("http://mirtin_inventory/retirarItemRevistar", JSON.stringify({
						item: itemData.key,
						target: target,
						slot: itemData.slot,
						amount: amount
					}));
				}

			}

			updateRevistar()
			requestRevistar()
		}
	});	
}


/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* OUTROS */
/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
const formatarNumero = n => {
	var n = n.toString();
	var r = '';
	var x = 0;

	for (var i = n.length; i > 0; i--) {
		r += n.substr(i - 1, 1) + (x == 2 && i != 1 ? '.' : '');
		x = x == 2 ? 0 : x + 1;
	}

	return r.split('').reverse().join('');
}
 

$(document).ready(function() {
    window.addEventListener("offline", function() {
		$(".inventory").css("display", "none")
		$.post("http://mirtin_inventory/invClose", JSON.stringify({}));
    });
});