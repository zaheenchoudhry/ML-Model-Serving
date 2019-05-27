output "elb_address" {
  value = "${aws_elb.elb_public.dns_name}"
}

output "ec2_public_mlserve_ip" {
  value = "${aws_instance.ec2_public_mlserve.public_ip}"
}

output "ec2_private_mlserve_ip" {
  value = "${aws_instance.ec2_public_mlserve.private_ip}"
}

output "ec2_public_mlserve_dnc" {
  value = "${aws_instance.ec2_public_mlserve.public_dns}"
}

output "ec2_mlserve_keypair_name" {
  value = "${aws_key_pair.keypair_ec2_mlserve.key_name}"
}
