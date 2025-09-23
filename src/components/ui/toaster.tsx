import * as React from 'react'
import * as Toast from '@radix-ui/react-toast'

export function Toaster() {
  const [open, setOpen] = React.useState(false)

  ;(globalThis as any).__ps_toast = (msg: string) => {
    ;(globalThis as any).__ps_toast_msg = msg
    setOpen(false)
    queueMicrotask(() => setOpen(true))
  }

  const message = (globalThis as any).__ps_toast_msg ?? ''

  return (
    <Toast.Provider swipeDirection="right">
      <Toast.Root
        open={open}
        onOpenChange={setOpen}
        className="fixed bottom-6 right-6 z-[100] max-w-sm rounded-xl border bg-white/95 p-4 shadow-lg backdrop-blur-md dark:border-neutral-800 dark:bg-neutral-900/95"
      >
        <Toast.Title className="mb-1 text-sm font-semibold leading-none tracking-tight">
          Notice
        </Toast.Title>
        <Toast.Description asChild>
          <div className="text-sm opacity-90">{message}</div>
        </Toast.Description>
        <Toast.Action altText="Close" asChild>
          <button
            className="mt-3 inline-flex items-center justify-center rounded-md border px-3 py-1 text-sm hover:bg-neutral-50 dark:border-neutral-700 dark:hover:bg-neutral-800"
            onClick={() => setOpen(false)}
          >
            Close
          </button>
        </Toast.Action>
      </Toast.Root>
      <Toast.Viewport className="fixed bottom-0 right-0 z-[100] m-0 flex w-96 max-w-[100vw] list-none flex-col gap-2 p-6 outline-none" />
    </Toast.Provider>
  )
}

export default Toaster
