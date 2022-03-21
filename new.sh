#!/bin/bash


PostName=${1:-"NewPost"}
hugo new posts/$(date +%Y/%m/%d)/${PostName}.md
