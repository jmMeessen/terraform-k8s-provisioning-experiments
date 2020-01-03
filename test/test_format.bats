#!/usr/bin/env bats

@test "running terraform fmt suggests no changes" {
    run terraform fmt -check -write=false -recursive
    [ "$status" -eq 0 ]
}