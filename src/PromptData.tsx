export default interface PromptData {
  ts: number,
  st: number,
  timer_start: number | null,
  timer_end: number | null,
  blink_end: number | null,
  message: string | null,
  headline: string | null,
}
