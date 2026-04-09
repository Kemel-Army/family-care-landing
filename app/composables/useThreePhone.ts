import { ref, onMounted, onBeforeUnmount, type Ref } from 'vue'

interface UseThreePhoneOptions {
  container: Ref<HTMLElement | null>
  /** Mouse position normalized to [-1, 1] range */
  mouseX?: Ref<number>
  mouseY?: Ref<number>
}

export function useThreePhone({ container, mouseX, mouseY }: UseThreePhoneOptions) {
  const isReady = ref(false)
  let THREE: any = null
  let renderer: any = null
  let scene: any = null
  let camera: any = null
  let phoneMesh: any = null
  let animFrameId: number | null = null

  const targetRotX = ref(0)
  const targetRotY = ref(0)

  function createPhoneGeometry(): any {
    const group = new THREE.Group()

    // Phone body — rounded box approximation
    const bodyGeo = new THREE.BoxGeometry(2.4, 4.8, 0.25, 4, 4, 1)
    const bodyMat = new THREE.MeshPhysicalMaterial({
      color: 0xf5f3fa,
      metalness: 0.1,
      roughness: 0.2,
      clearcoat: 0.8,
      clearcoatRoughness: 0.15,
      reflectivity: 0.5,
    })
    const body = new THREE.Mesh(bodyGeo, bodyMat)
    group.add(body)

    // Screen — slightly recessed
    const screenGeo = new THREE.PlaneGeometry(2.1, 4.2)
    const screenMat = new THREE.MeshPhysicalMaterial({
      color: 0xffffff,
      metalness: 0,
      roughness: 0.1,
      emissive: 0xe8e4f5,
      emissiveIntensity: 0.3,
    })
    const screen = new THREE.Mesh(screenGeo, screenMat)
    screen.position.z = 0.131
    group.add(screen)

    // Screen content — timeline dots (3 circles)
    const dotPositions = [
      { y: 1.2, color: 0x8b7ec8 },  // Done — primary
      { y: 0.0, color: 0xe8a0bf },   // Current — secondary (pulsing)
      { y: -1.2, color: 0xcbd5e1 },  // Upcoming — gray
    ]

    dotPositions.forEach(({ y, color }) => {
      const dotGeo = new THREE.CircleGeometry(0.12, 16)
      const dotMat = new THREE.MeshBasicMaterial({ color })
      const dot = new THREE.Mesh(dotGeo, dotMat)
      dot.position.set(-0.6, y, 0.14)
      group.add(dot)

      // Line connecting dots
      if (y > -1.2) {
        const lineGeo = new THREE.PlaneGeometry(0.03, 1.0)
        const lineMat = new THREE.MeshBasicMaterial({ color: 0xe4dff0 })
        const line = new THREE.Mesh(lineGeo, lineMat)
        line.position.set(-0.6, y - 0.6, 0.135)
        group.add(line)
      }

      // Text placeholder bars
      const barGeo = new THREE.PlaneGeometry(1.0, 0.08)
      const barMat = new THREE.MeshBasicMaterial({ color: 0xe4dff0 })
      const bar = new THREE.Mesh(barGeo, barMat)
      bar.position.set(0.2, y + 0.15, 0.135)
      group.add(bar)

      const bar2Geo = new THREE.PlaneGeometry(0.6, 0.06)
      const bar2 = new THREE.Mesh(bar2Geo, barMat)
      bar2.position.set(0.0, y - 0.05, 0.135)
      group.add(bar2)
    })

    return group
  }

  function init() {
    if (!container.value) return

    const width = container.value.clientWidth
    const height = container.value.clientHeight

    // Renderer
    renderer = new THREE.WebGLRenderer({
      antialias: true,
      alpha: true,
    })
    renderer.setSize(width, height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
    renderer.outputColorSpace = THREE.SRGBColorSpace
    container.value.appendChild(renderer.domElement)

    // Scene
    scene = new THREE.Scene()

    // Camera
    camera = new THREE.PerspectiveCamera(35, width / height, 0.1, 100)
    camera.position.set(0, 0, 10)

    // Lights
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.6)
    scene.add(ambientLight)

    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8)
    directionalLight.position.set(5, 5, 5)
    scene.add(directionalLight)

    const rimLight = new THREE.DirectionalLight(0x8b7ec8, 0.3)
    rimLight.position.set(-3, 2, -2)
    scene.add(rimLight)

    // Phone
    phoneMesh = createPhoneGeometry()
    phoneMesh.rotation.y = THREE.MathUtils.degToRad(5)
    phoneMesh.rotation.x = THREE.MathUtils.degToRad(-3)
    scene.add(phoneMesh)

    isReady.value = true
    animate()
  }

  function animate() {
    animFrameId = requestAnimationFrame(animate)

    if (!phoneMesh || !renderer || !scene || !camera) return

    // Mouse-driven rotation (smooth lerp)
    const mx = mouseX?.value ?? 0
    const my = mouseY?.value ?? 0
    targetRotY.value = THREE.MathUtils.degToRad(5) + mx * THREE.MathUtils.degToRad(5)
    targetRotX.value = THREE.MathUtils.degToRad(-3) + my * THREE.MathUtils.degToRad(5)

    phoneMesh.rotation.y += (targetRotY.value - phoneMesh.rotation.y) * 0.05
    phoneMesh.rotation.x += (targetRotX.value - phoneMesh.rotation.x) * 0.05

    // Subtle idle float
    phoneMesh.position.y = Math.sin(Date.now() * 0.001) * 0.08

    renderer.render(scene, camera)
  }

  function handleResize() {
    if (!container.value || !renderer || !camera) return
    const width = container.value.clientWidth
    const height = container.value.clientHeight
    renderer.setSize(width, height)
    camera.aspect = width / height
    camera.updateProjectionMatrix()
  }

  onMounted(async () => {
    // Only init on desktop (skip on mobile for performance)
    if (window.innerWidth < 768) return
    THREE = await import('three')
    init()
    window.addEventListener('resize', handleResize, { passive: true })
  })

  onBeforeUnmount(() => {
    if (animFrameId) cancelAnimationFrame(animFrameId)
    window.removeEventListener('resize', handleResize)
    renderer?.dispose()
    renderer?.domElement.remove()
    renderer = null
  })

  return { isReady }
}
