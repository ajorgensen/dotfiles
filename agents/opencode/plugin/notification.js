export const NotificationPlugin = async ({ client, $ }) => {
  return {
    "session.idle": async ({ sessionID }) => {
      const session = await client.session.get({ path: { id: sessionID } })
      const title = session.data?.title ?? "Session completed"
      await $`terminal-notifier -title "opencode" -subtitle "Session completed" -message ${title}`
    },
  }
}
