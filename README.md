# AWS Route53 DynDNS Docker container

This is a simple Docker container that does one thing. It regularly polls [OpenDNS](https://diagnostic.opendns.com/myip) for it's current public IP, and updates a specified AWS Route53 Host Zone accordingly.

It's not that intelligent. It only keeps state while running and will only update AWS Route53 if it determines your IP has changed. It assumes it's the only thing update your DNS record, and will always update the record when started.

I made this for myself as a DynDNS container for Unraid, but feel free to use it if it suits your needs.

## Requirements

This Docker container needs AWS Access Keys for an IAM user with at least the following permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": "arn:aws:route53:::hostedzone/YOURHOSTEDZONEID",
            "Effect": "Allow"
        }
    ]
}
```

## Environment variables

- AWS_ACCESS_KEY_ID: The AWS Access Key ID for the IAM user.
- AWS_SECRET_ACCESS_KEY: The AWS Secret Access Key for the IAM user.
- ROUTE53_HOSTED_ZONE_ID: The Hosted Zone ID of the hosted zone to update.
- ROUTE53_RECORD: The record name (FQDN) to update.
- ROUTE53_TTL: The TTL of the record, but also determines how often the check is run.
