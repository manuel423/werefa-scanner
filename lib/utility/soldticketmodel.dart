import 'dart:convert';

Soldticket soldticketFromJson(String str) => Soldticket.fromJson(json.decode(str));

String soldticketToJson(Soldticket data) => json.encode(data.toJson());

class Soldticket{
  String ticket_id;
  int ticket_num;

  Soldticket({
    this.ticket_id,
    this.ticket_num,
  });

  factory Soldticket.fromJson(Map<String, dynamic> json) => Soldticket(
    ticket_id: json['ticketid'],
    ticket_num: json['ticketnum'],
);

  Map<String, dynamic> toJson() =>{
    "ticketid": ticket_id,
    "ticketnum": ticket_num,
  };
}