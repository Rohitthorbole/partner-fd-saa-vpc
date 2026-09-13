# AWS VPC Architecture Notes

This project represents a simple AWS VPC architecture with public and private
subnets.

## Architecture overview

```text
                           Internet
                              |
                    Internet Gateway (IGW)
                              |
                 Public subnet: 10.0.1.0/24
                     |                    |
              Public route table     NAT Gateway
                                          |
                              Private route table
                                          |
                 Private subnet: 10.0.2.0/24
```

## VPC

The VPC uses the address range `10.0.0.0/16`. This is the main private network
that contains both subnets, route tables, the NAT Gateway, and the network ACL.

## Subnets

### Public subnet

The public subnet uses `10.0.1.0/24`.

It is public because its route table sends internet-bound traffic
(`0.0.0.0/0`) to the Internet Gateway. Resources in this subnet can have
direct internet connectivity when they have suitable public addressing and
security rules.

### Private subnet

The private subnet uses `10.0.2.0/24`.

It does not have a direct route to the Internet Gateway. Its default route
uses the NAT Gateway, allowing resources to initiate outbound internet
connections without accepting unsolicited inbound connections from the
internet.

Both subnets are currently in Availability Zone `us-east-1a`.

## Internet Gateway

The Internet Gateway is attached to the VPC. It provides the path between the
VPC and the public internet for resources using a public-subnet route table.

## NAT Gateway

The NAT Gateway is used by the private subnet for outbound internet access.
It uses an Elastic IP and is placed in the public subnet so that it can reach
the Internet Gateway.

Traffic flow from a private resource is:

```text
Private resource
    → Private route table
    → NAT Gateway
    → Public route table
    → Internet Gateway
    → Internet
```

Return traffic is translated back by the NAT Gateway. External systems cannot
start a new connection directly to the private resource through the NAT
Gateway.

## Route tables

### Public route table

The public route table is associated with the public subnet and sends the
default route to the Internet Gateway.

### Private route table

The private route table is associated with the private subnet and sends the
default route to the NAT Gateway.

## Network ACL

The network ACL provides subnet-level traffic filtering. It is stateless, so
inbound and outbound traffic must be permitted separately.

The current design includes:

- Inbound TCP port `80` for HTTP traffic.
- Outbound TCP ephemeral ports `1024–65535`.

Network ACL rules are evaluated in rule-number order. The first matching rule
is applied.

## Security flow summary

```text
Internet → IGW → Public subnet

Private subnet → NAT Gateway → IGW → Internet

Internet ✕→ Private subnet directly
```