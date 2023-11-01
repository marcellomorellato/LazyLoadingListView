import SwiftUI

struct LazyLoadingListView<Data, Cell>: View where Data: RandomAccessCollection,
                                                   Data.Element: Identifiable & Equatable,
                                                   Cell: View {
    @State private var data: [Data.Element]
    @Binding var currentPage: Int
    let batchSize: Int
    let totalRecords: Int
    let prefetchThrottleDelay: Double
    let dataProvider: (Binding<Int>, Int, Int, @escaping ([Data.Element]) -> Void) -> Void
    let cell: (Data.Element) -> Cell
    
    @State private var isNearBottom = false // Track list visibility
    @State private var isLoading = false // Track loading state
    
    init(currentPage: Binding<Int>, batchSize: Int, totalRecords: Int, prefetchThrottleDelay: Double, dataProvider: @escaping (Binding<Int>, Int, Int, @escaping ([Data.Element]) -> Void) -> Void, cell: @escaping (Data.Element) -> Cell) {
        self._data = State(initialValue: [])
        self._currentPage = currentPage
        self.batchSize = batchSize
        self.totalRecords = totalRecords
        self.prefetchThrottleDelay = prefetchThrottleDelay
        self.dataProvider = dataProvider
        self.cell = cell
    }
    
    var body: some View {
        ZStack(alignment: .bottom){
            List {
                ForEach(data) { item in
                    cell(item)
                        .onAppear {
                            let triggerIndex = Int(Double(data.count) * 0.7)
                            let prefetchTrigger = item == data[triggerIndex]
                            let hasDataToLoad = data.count < totalRecords
                            let isLastElement = item == data.last && hasDataToLoad

                            if (prefetchTrigger && hasDataToLoad && !isLoading) || (isLastElement && !isLoading) {
                                prefetchNextBatch()
                            }

                        }
                }
            }
            .onAppear {
                loadInitialData()
            }
            if isLoading {
                LoadingIndicatorView()
            }
        }
    }
    
    func loadInitialData() {
        isLoading = true
        dataProvider($currentPage, batchSize, totalRecords) { newItems in
            data.append(contentsOf: newItems)
            isLoading = false
        }
    }
    
    func prefetchNextBatch() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + prefetchThrottleDelay) {
            dataProvider($currentPage, batchSize, totalRecords) { newItems in
                data.append(contentsOf: newItems)
                isLoading = false
            }
        }
    }
}

struct LoadingIndicatorView: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding(.trailing, 10)
            Text("Loading...")
            Spacer()
        }
        .background(Color.white.opacity(0.8))
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let dataProvider = TestDataProvider()
        @State var currentPage: Int = 0
        LazyLoadingListView<[DataElement], CellView>(
            currentPage: $currentPage,
            batchSize: 10,
            totalRecords: 100,
            prefetchThrottleDelay: 0.5,
            dataProvider: dataProvider.fetchData,
            cell: { item in
                CellView(item: item)
            }
        )
    }
}

class TestDataProvider {
    func fetchData(currentPage: Binding<Int>, batchSize: Int, totalRecords: Int,
                   completion: @escaping ([DataElement]) -> Void) {
        DispatchQueue.global().async {
            let start = currentPage.wrappedValue * batchSize
            if start >= totalRecords {
                return // No more data to load
            }

            let end = min(start + batchSize, totalRecords)
            
            var newItems: [DataElement] = []

            for index in start..<end {
                let newItem = DataElement(id: UUID(), value: "Item \(index + 1)")
                newItems.append(newItem)
            }

            // Simulate database or network delay
            sleep(1)

            // Update the data on the main queue
            DispatchQueue.main.async {
                completion(newItems)
                currentPage.wrappedValue += 1
            }
        }
    }
}


struct CellView: View {
    var item: DataElement

    var body: some View {
        Text(item.value)
            .frame(height: 50)
    }
}

struct DataElement: Identifiable, Equatable {
    var id: UUID
    var value: String
    
    static func == (lhs: DataElement, rhs: DataElement) -> Bool {
            return lhs.id == rhs.id && lhs.value == rhs.value
        }
}
