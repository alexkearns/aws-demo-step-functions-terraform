# Distributed Map

## Summary

This example demonstrates the 'Distributed Map' state type, a way to run
massively-parallel tasks within a state machine. Prior to the introduction of
this state type at re:Invent 2022, high degrees of parallelism were only
possible by nesting 'Map' states inside each other with an intermediate state
machine. This added complexity and cognitive overhead. Whilst 'Distributed Map'
utilises the same concept, it has an increased limit of 10k concurrent
executions rather than the ~1600 possible previously.

## Usage

First, with AWS credentials set in your shell, run the following commands.

```sh
terraform init
terraform apply
```

In the AWS console (Ireland), you can then start an execution of the demo state
machine that's been deployed. Success!

## Useful links

- [Announcement blog post](https://aws.amazon.com/blogs/aws/step-functions-distributed-map-a-serverless-solution-for-large-scale-parallel-data-processing/)
- [Documentation](https://docs.aws.amazon.com/step-functions/latest/dg/concepts-asl-use-map-state-distributed.html)
