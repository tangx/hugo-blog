---
date: "2021-06-30T00:00:00Z"
description: 使用 environment , 在 gitlab branch 被删除的时候，触发 CI
keywords: gitlab, branch delete, ci
tags:
- gitlab
title: 分支删除触发 gitlab CI
---

# 分支删除触发 gitlab CI

使用 environment , 在 gitlab branch 被删除的时候，触发 CI

### Stopping an environment

1. 尝试在 **JOB A** 中申明一个变量，并停止。
2. 使用 [`on_stop` action](https://docs.gitlab.com/ee/ci/yaml/README.html#environmenton_stop) 动作, 在删除分支时(同时删除变量), 触发运行 **JOB B**

#### Stop an environment when a branch is deleted

> [Stop an environment when a branch is deleted GitLab](https://docs.gitlab.com/ee/ci/environments/index.html#stop-an-environment-when-a-branch-is-deleted)  

在 CI 中配置一个 **环境变量** , 当 branch 被删除的时候清理该 **环境变量**， 触发 `on_stop` 动作， 需求。

随后这段代码是节选，在 `delpoy_action` job 中创建了一个变量 `clean/$CI_COMMIT_REF_NAME`, 并预置了一个 **动作触发器** `on_stop`。
当变量被删除的时候， 就会触发 `deploy_clean` job

```yaml
delpoy_action:
  stage: deploy
  script:
    - echo "Deploy a app"
  environment:
    name: clean/$CI_COMMIT_REF_NAME # 预置变量
    url: https://$CI_ENVIRONMENT_SLUG.example.com # 其实没什么用
    on_stop: deploy_clean  # 预置触发器 及 触发动作

deploy_clean: # 清理动作
  stage: deploy
  script:
    - echo "Remove app"
  environment:
    name: clean/$CI_COMMIT_REF_NAME
    action: stop # 删除变量
  variables:
    GIT_STRATEGY: none  # 这里需要设置 git 策略为 none。 否则默认策略是 fetch 或者 clone, 会因为 branch 被删除而失败。

```

有几点需要注意:

1. 在 `deploy_action` job 中需要设置 **环境变量与触发器** 
2. 在 `deploy_clean` job 中需要设置 `GIT_STRATEGY: none` 避免默认 git 操作而造成失败: [Git Strategy - GitLab](https://docs.gitlab.com/ee/ci/runners/configure_runners.html#git-strategy)
3. 环境变量本身是有作用域的(仓库, 分支, Commit 等)， 其选用应该选择与 `branch/tag` 生命周期一致的变量, 例如这里的 `clean/$CI_COMMIT_REF_NAME`: [Ref Specs for Runners - GitLab](https://docs.gitlab.com/ee/ci/pipelines/index.html#ref-specs-for-runners)
4. `delpoy_action` 与 `delpoy_clean` 两个 job 的 rules 应该保持一致， 否则可能造成 pipeline 不能覆盖的问题。


## 参考资料

### Ref Specs for Runners

> [Ref Specs for Runners - GitLab](https://docs.gitlab.com/ee/ci/pipelines/index.html#ref-specs-for-runners)  

When a runner picks a pipeline job, GitLab provides that job’s metadata. This includes the  [Git refspecs](https://git-scm.com/book/en/v2/Git-Internals-The-Refspec) , which indicate which ref (branch, tag, and so on) and commit (SHA1) are checked out from your project repository.

The refs `refs/heads/<name>` and `refs/tags/<name>` exist in your project repository. GitLab generates the special ref `refs/pipelines/<id>` during a running pipeline job. This ref can be created even after the associated branch or tag has been deleted. It’s therefore useful in some features such as  [automatically stopping an environment](https://docs.gitlab.com/ee/ci/environments/index.html#stopping-an-environment) , and  [merge trains](https://docs.gitlab.com/ee/ci/merge_request_pipelines/pipelines_for_merged_results/merge_trains/index.html)  that might run pipelines after branch deletion.

### Git Strategy

> [Git Strategy - GitLab](https://docs.gitlab.com/ee/ci/runners/configure_runners.html#git-strategy)
There are three possible values: `clone`, `fetch`, and `none` . 

If left unspecified, jobs use the  [project’s pipeline setting](https://docs.gitlab.com/ee/ci/pipelines/settings.html#git-strategy) .

