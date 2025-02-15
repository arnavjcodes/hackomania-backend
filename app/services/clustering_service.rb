class ClusteringService
    def initialize(version = 1)
      @version = version
    end
  
    def perform_clustering
      users = User.all
      normalized_data = normalize_data(users)
      clusters = perform_kmeans(normalized_data)
      save_clusters(users, clusters)
    end
  
    private
  
    def normalize_data(users)
      # Extract and normalize interest weights
      all_interests = users.flat_map { |u| u.interests.keys }.uniq
      users.map do |user|
        all_interests.map { |interest| user.interests[interest].to_f }
      end
    end
  
    def perform_kmeans(data, clusters = 5)
      require 'kmeans-clusterer'
      kmeans = KMeansClusterer.run(clusters, data)
      kmeans.clusters.map(&:points).map { |pts| pts.map(&:index) }
    end
  
    def save_clusters(users, clusters)
      ClusterAssignment.transaction do
        clusters.each_with_index do |user_indices, cluster_id|
          user_indices.each do |user_idx|
            user = users[user_idx]
            user.cluster_assignments.create!(
              cluster_id: cluster_id,
              version: @version
            )
          end
        end
      end
    end
  end