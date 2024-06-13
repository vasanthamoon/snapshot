resource "aws_volume_attachment" "detach_old_volume" {
  device_name  = "/dev/sdh"
  volume_id    = "vol-id"  # replace with existing volume ID
  instance_id  = "ami-id/image-id"    # replace with your instance ID
  force_detach = true

  lifecycle {
    ignore_changes = [volume_id]  # prevent terraform from trying to reattach the existing volume
  }
}

resource "aws_ebs_snapshot" "existing_volume_snapshot" {
  volume_id = "vol-xxxxxxxx"  # replace with existing volume ID
  tags = {
    Name = "MyVolumeSnapshot"
  }
}

resource "aws_ebs_volume" "new_volume" {
  availability_zone = "us-west-2a"
  snapshot_id       = aws_ebs_snapshot.existing_volume_snapshot.id
  tags = {
    Name = "NewVolumeFromSnapshot"
  }
}

resource "aws_volume_attachment" "attach_new_volume" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.new_volume.id
  instance_id = "ami-id"    # replace with instance ID

  depends_on = [aws_volume_attachment.detach_old_volume]
}



output "new_volume_id" {
  value = aws_ebs_volume.new_volume.id
}

output "new_snapshot_id" {
  value = aws_ebs_snapshot.existing_volume_snapshot.id
}
